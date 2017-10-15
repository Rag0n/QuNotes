//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

extension UI.Note {
    struct EvaluatorResult {
        let updates: [ViewControllerUpdate]
        let actions: [Action]
        let model: Model
    }

    static func initialModel(withNote: Note) -> Model {
        return Model(note: withNote)
    }

    static func evaluateController(event: ViewControllerEvent, model: Model) -> EvaluatorResult {
        var actions: [Action] = []
        var updates: [ViewControllerUpdate] = []

        switch event {
        case .didLoad:
            updates = [
                .updateTitle(title: model.note.title),
                .updateContent(content: model.note.content),
                .showTags(tags: model.note.tags)
            ]
        case let .changeContent(newContent):
            actions = [.updateContent(content: newContent)]
        case let .changeTitle(newTitle):
            actions = [.updateTitle(title: newTitle)]
        case .delete:
            actions = [.delete]
        case let .addTag(tag):
            actions = [.addTag(tag: tag)]
        case let .removeTag(tag):
            actions = [.removeTag(tag: tag)]
        }

        return EvaluatorResult(updates: updates, actions: actions, model: model)
    }

    static func evaluateCoordinator(event: CoordinatorEvent, model: Model) -> EvaluatorResult {
        var actions: [Action] = []
        var updates: [ViewControllerUpdate] = []
        var newModel = model

        switch event {
        case let .didUpdateTitle(note):
            updates = [.updateTitle(title: note.title)]
            newModel = Model(note: note)
        case let .didUpdateContent(note):
            updates = [.updateContent(content: note.content)]
            newModel = Model(note: note)
        case let .didAddTag(note, tag):
            updates = [.addTag(tag: tag)]
            newModel = Model(note: note)
        case let .didRemoveTag(note, tag):
            updates = [.removeTag(tag: tag)]
            newModel = Model(note: note)
        case .didDeleteNote:
            actions = [.finish]
        case let .didFailToUpdateTitle(error):
            let errorMessage = error.error.localizedDescription
            updates = [
                .updateTitle(title: model.note.title),
                .showError(error: "Failed to update note's title", message: errorMessage)
            ]
        case let .didFailToUpdateContent(error):
            let errorMessage = error.error.localizedDescription
            updates = [
                .updateContent(content: model.note.content),
                .showError(error: "Failed to update note's content", message: errorMessage)
            ]
        case let .didFailToAddTag(error):
            let errorMessage = error.error.localizedDescription
            updates = [
                .showTags(tags: model.note.tags),
                .showError(error: "Failed to add tag", message: errorMessage)
            ]
        case let .didFailToRemoveTag(error):
            let errorMessage = error.error.localizedDescription
            updates = [
                .showTags(tags: model.note.tags),
                .showError(error: "Failed to remove tag", message: errorMessage)
            ]
        case let .didFailToDeleteNote(error):
            let errorMessage = error.error.localizedDescription
            updates = [.showError(error: "Failed to delete note", message: errorMessage)]
        }

        return EvaluatorResult(updates: updates, actions: actions, model: newModel)
    }
}

