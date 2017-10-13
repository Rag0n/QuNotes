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
        let updates: [ViewControllerUpdate] = []

        switch event {
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

    static func evaluateNoteUseCase(event: NoteUseCaseEvent, model: Model) -> EvaluatorResult {
        let actions: [Action] = []
        var updates: [ViewControllerUpdate] = []
        var newModel = model

        switch event {
        case let .didUpdateNote(note):
            updates = []
        case let .didDeleteNote(note):
            updates = []
        case let .didFailToUpdateNote(note):
            updates = []
        case let .didFailToDeleteNote(note):
            updates = []
        }

        return EvaluatorResult(updates: updates, actions: actions, model: newModel)
    }
}

