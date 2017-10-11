//
//  NotebookEvaluator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 11.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

extension NotebookNamespace {
    struct EvaluatorResult {
        let updates: [ViewControllerUpdate]
        let actions: [Action]
        let model: Model
    }

    static func initialModel() -> Model {
        return Model()
    }

    static func evaluateController(event: ViewControllerEvent, model: Model) -> EvaluatorResult {
        var actions: [Action] = []
        let updates: [ViewControllerUpdate] = []
        let result = EvaluatorResult(updates: updates, actions: actions, model: model)

        switch event {
        case .addNote:
            return result
        case .selectNote(let index):
            return result
        case .deleteNote(let index):
            return result
        case .deleteNotebook:
            return result
        case .filterNotes(let filter):
            return result
        case .didStartToEditTitle:
            return result
        case .didFinishToEditTitle(let newTitle):
            return result
        }

        return result
    }
}
