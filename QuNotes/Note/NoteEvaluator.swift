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
            case let .changeContent(newContent):
                let newCells = [Core.Note.Cell(type: .text, data: newContent)]
                newModel = model |> Model.lens.cells .~ newCells
                actions = [.updateCells(newCells)]
                effects = [.updateContent(newContent)]
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
                effects = [.updateContent(content.cells.first?.data ?? "")]
            case let .didDeleteNote(error):
                if let error = error {
                    actions = [.showError(title: "Failed to delete note", message: error.localizedDescription)]
                } else {
                    actions = [.finish]
                }
            case let .didUpdateTitle(oldTitle, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.title .~ oldTitle
                actions = [.showError(title: "Failed to update title", message: error.localizedDescription)]
                effects = [.updateTitle(oldTitle)]
            case let .didUpdateCells(oldCells, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.cells .~ oldCells
                actions = [.showError(title: "Failed to update content", message: error.localizedDescription)]
                effects = [.updateContent(oldCells.first?.data ?? "")]
            case let .didAddTag(tag, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.tags .~ model.tags.removing(tag)
                actions = [.showError(title: "Failed to add tag", message: error.localizedDescription)]
                effects = [.removeTag(tag)]
            case let .didRemoveTag(tag, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.tags .~ model.tags.appending(tag)
                actions = [.showError(title: "Failed to remove tag", message: error.localizedDescription)]
                effects = [.addTag(tag)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}
