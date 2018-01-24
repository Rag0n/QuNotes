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

        func evaluate(event: ViewEvent) -> Evaluator {
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
            case let .changeCell(newContent, index):
                guard index < model.cells.count else { break }
                let newCell = Core.Note.Cell(type: .text, data: newContent)
                let newCells = model.cells.replacing(at: index, new: newCell)
                newModel = model |> Model.lens.cells .~ newCells
                actions = [.updateCells(newCells)]
                effects = [.updateCell(index: index, cells: newCells.stringifyCells())]
            case .addCell:
                let newCell = Core.Note.Cell(type: .text, data: "")
                let newCells = model.cells.appending(newCell)
                newModel = model |> Model.lens.cells .~ newCells
                actions = [.updateCells(newCells)]
                effects = [.addCell(index: model.cells.count, cells: newCells.stringifyCells())]
            case let .removeCell(index):
                let newCells = model.cells.removing(at: index)
                newModel = model |> Model.lens.cells .~ newCells
                actions = [.updateCells(newCells)]
                effects = [.removeCell(index: index, cells: newCells.stringifyCells())]
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

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case let .didLoadContent(content):
                newModel = model |> Model.lens.cells .~ content.cells
                effects = [.updateCells(content.cells.stringifyCells())]
            case let .didDeleteNote(error):
                if let error = error {
                    actions = [.showFailure(.deleteNote, reason: error.localizedDescription)]
                } else {
                    actions = [.finish]
                }
            case let .didUpdateTitle(oldTitle, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.title .~ oldTitle
                actions = [.showFailure(.updateTitle, reason: error.localizedDescription)]
                effects = [.updateTitle(oldTitle)]
            case let .didUpdateCells(oldCells, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.cells .~ oldCells
                actions = [.showFailure(.updateContent, reason: error.localizedDescription)]
                effects = [.updateCells(oldCells.stringifyCells())]
            case let .didAddTag(tag, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.tags .~ model.tags.removing(tag)
                actions = [.showFailure(.addTag, reason: error.localizedDescription)]
                effects = [.removeTag(tag)]
            case let .didRemoveTag(tag, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.tags .~ model.tags.appending(tag)
                actions = [.showFailure(.removeTag, reason: error.localizedDescription)]
                effects = [.addTag(tag)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}

// MARK: - Private

private extension Array where Element == Core.Note.Cell {
    func stringifyCells() -> [String] {
        return self.map { $0.data }
    }
}
