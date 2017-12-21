//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result
import Prelude
import Core

extension Note {
    struct Evaluator {
        let effects: [ViewEffect]
        let actions: [Action]
        let model: Model

        init(note: Core.Note.Meta, content: String, isNew: Bool) {
            effects = []
            actions = []
            model = Model(title: note.title, tags: note.tags, content: content, isNew: isNew)
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
                    .updateTitle(title: model.title),
                    .showTags(tags: model.tags)
                ]
                if model.isNew {
                    effects += [.focusOnTitle]
                }
            case let .changeContent(newContent):
                newModel = model |> Model.lens.content .~ newContent
                actions = [.updateContent(content: newContent)]
                effects = [.updateContent(content: newContent)]
            case let .changeTitle(newTitle):
                newModel = model |> Model.lens.title .~ newTitle
                actions = [.updateTitle(title: newTitle)]
                effects = [.updateTitle(title: newTitle)]
            case .delete:
                actions = [.deleteNote]
            case let .addTag(tag):
                newModel = model |> Model.lens.tags .~ model.tags.appending(tag)
                actions = [.addTag(tag: tag)]
                effects = [.addTag(tag: tag)]
            case let .removeTag(tag):
                newModel = model |> Model.lens.tags .~ model.tags.removing(tag)
                actions = [.removeTag(tag: tag)]
                effects = [.removeTag(tag: tag)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
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
                effects = [.updateTitle(title: oldTitle)]
            case let .didAddTag(tag, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.tags .~ model.tags.removing(tag)
                actions = [.showError(title: "Failed to add tag", message: error.localizedDescription)]
                effects = [.removeTag(tag: tag)]
            case let .didRemoveTag(tag, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.tags .~ model.tags.appending(tag)
                actions = [.showError(title: "Failed to remove tag", message: error.localizedDescription)]
                effects = [.addTag(tag: tag)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}
