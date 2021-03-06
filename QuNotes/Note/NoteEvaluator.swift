//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Prelude
import Core

extension Note {
    struct Evaluator {
        let effects: [ViewEffect]
        let actions: [Action]
        let model: Model

        init(note: Core.Note.Meta, cells: [Core.Note.Cell], isNew: Bool) {
            effects = []
            actions = []
            model = Model(title: note.title, tags: note.tags, cells: cells, isNew: isNew)
        }

        fileprivate init(effects: [ViewEffect], actions: [Action], model: Model) {
            self.effects = effects
            self.actions = actions
            self.model = model
        }

        func evaluating(event: ViewEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case .didLoad:
                effects = [
                    .updateTitle(model.title),
                    .showTags(model.tags)
                ]
                if model.isNew {
                    effects += [.focusOnTitle]
                }
            case let .changeCellContent(newContent, index):
                guard index < model.cells.count else { break }
                let newCell = Core.Note.Cell(type: model.cells[index].type, data: newContent)
                newModel = model |> Model.lens.cells .~ model.cells.replacing(at: index, with: newCell)
                actions = [.updateCells(newModel.cells)]
                effects = [.updateCell(index: index, cells: viewModels(from: newModel))]
            case let .changeCellType(newType, index):
                guard index < model.cells.count else { break }
                let newCell = Core.Note.Cell(type: newType, data: model.cells[index].data)
                newModel = model |> Model.lens.cells .~ model.cells.replacing(at: index, with: newCell)
                actions = [.updateCells(newModel.cells)]
                effects = [.updateCell(index: index, cells: viewModels(from: newModel))]
            case .addCell:
                let newCell = Core.Note.Cell(type: .markdown, data: "")
                newModel = model |> Model.lens.cells .~ model.cells.appending(newCell)
                actions = [.updateCells(newModel.cells)]
                effects = [.addCell(index: model.cells.count, cells: viewModels(from: newModel))]
            case let .removeCell(index):
                newModel = model |> Model.lens.cells .~ model.cells.removing(at: index)
                actions = [.updateCells(newModel.cells)]
                effects = [.removeCell(index: index, cells: viewModels(from: newModel))]
            case let .changeTitle(newTitle):
                newModel = model |> Model.lens.title .~ newTitle
                actions = [.updateTitle(newTitle)]
                effects = [.updateTitle(newTitle)]
            case .delete:
                actions = [.deleteNote]
            case let .addTag(tag):
                newModel = model |> Model.lens.tags .~ model.tags.appending(tag)
                actions = [.addTag(tag)]
                effects = [.addTag(tag)]
            case let .removeTag(tag):
                newModel = model |> Model.lens.tags .~ model.tags.removing(tag)
                actions = [.removeTag(tag)]
                effects = [.removeTag(tag)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }

        func evaluating(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case let .didLoadContent(content):
                newModel = model |> Model.lens.cells .~ content.cells
                effects = [.updateCells(viewModels(from: newModel))]
            case let .didDeleteNote(error):
                if let error = error {
                    actions = [.showFailure(.deleteNote, reason: error.localizedDescription)]
                } else {
                    actions = [.finish]
                }
            case let .didUpdateTitle(oldTitle, note, error):
                guard let error = error else {
                    actions = [.didUpdateNote(note)]
                    break
                }
                newModel = model |> Model.lens.title .~ oldTitle
                actions = [.showFailure(.updateTitle, reason: error.localizedDescription)]
                effects = [.updateTitle(oldTitle)]
            case let .didUpdateCells(oldCells, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.cells .~ oldCells
                actions = [.showFailure(.updateContent, reason: error.localizedDescription)]
                effects = [.updateCells(viewModels(from: newModel))]
            case let .didAddTag(tag, note, error):
                guard let error = error else {
                    actions = [.didUpdateNote(note)]
                    break
                }
                newModel = model |> Model.lens.tags .~ model.tags.removing(tag)
                actions = [.showFailure(.addTag, reason: error.localizedDescription)]
                effects = [.removeTag(tag)]
            case let .didRemoveTag(tag, note, error):
                guard let error = error else {
                    actions = [.didUpdateNote(note)]
                    break
                }
                newModel = model |> Model.lens.tags .~ model.tags.appending(tag)
                actions = [.showFailure(.removeTag, reason: error.localizedDescription)]
                effects = [.addTag(tag)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}

// MARK: - Private

private extension Note {
    static func viewModels(from model: Model) -> [CellViewModel] {
        return model.cells.map(viewModelFromCell)
    }

    static func viewModelFromCell(_ cell: Core.Note.Cell) -> CellViewModel {
        return CellViewModel(content: cell.data, type: cell.type)
    }
}
