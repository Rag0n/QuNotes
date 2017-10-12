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

    static func initialModel(withNotebook: Notebook) -> Model {
        return Model(notebook: withNotebook, notes: [])
    }

    static func evaluateController(event: ViewControllerEvent, model: Model) -> EvaluatorResult {
        var actions: [Action] = []
        var updates: [ViewControllerUpdate] = []

        switch event {
        case .addNote:
            actions = [.addNote]
        case .selectNote(let index):
            let note = model.notes[index]
            actions = [.showNote(note: note)]
        case .deleteNote(let index):
            let note = model.notes[index]
            actions = [.deleteNote(note: note)]
        case .deleteNotebook:
            actions = [.deleteNotebook(notebook: model.notebook)]
        case .filterNotes(let filter):
            var filteredNotes = model.notes
            if let filter = filter {
                filteredNotes = model.notes.filter { $0.title.lowercased().contains(filter) }
            }
            let noteTitles = filteredNotes.map { $0.title }
            updates = [.updateAllNotes(notes: noteTitles)]
        case .didStartToEditTitle:
            updates = [.hideBackButton]
        case .didFinishToEditTitle(let newTitle):
            updates = [.showBackButton]
            actions = [.updateNotebook(notebook: model.notebook, title: newTitle ?? "")]
        }

        return EvaluatorResult(updates: updates, actions: actions, model: model)
    }
}
