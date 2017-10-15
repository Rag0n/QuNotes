//
//  NotebookEvaluator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 11.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

extension UI.Notebook {
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

    static func evaluateCoordinator(event: CoordinatorEvent, model: Model) -> EvaluatorResult {
        var actions: [Action] = []
        var updates: [ViewControllerUpdate] = []
        var newModel = model

        switch event {
        case let .didUpdateNotes(notes):
            let sortedNotes = notes.sorted(by: defaultNoteSorting)
            let noteTitles = sortedNotes.map { $0.title }
            updates = [.updateAllNotes(notes: noteTitles)]
            newModel = Model(notebook: model.notebook, notes: sortedNotes)
        case let .didAddNote(note):
            let newNotes = model.notes + [note]
            let sortedNotes = newNotes.sorted(by: defaultNoteSorting)
            newModel = Model(notebook: model.notebook, notes: sortedNotes)
            actions = [.showNote(note: note)]
        case let .didDeleteNote(note):
            let indexOfDeletedNote = model.notes.index(of: note)!
            let updatedNotes = model.notes.removeWithoutMutation(at: indexOfDeletedNote)
            let noteTitles = updatedNotes.map { $0.title }
            updates = [.deleteNote(index: indexOfDeletedNote, notes: noteTitles)]
            newModel = Model(notebook: model.notebook, notes: updatedNotes)
        case let .didUpdateNotebook(notebook):
            updates = [.updateTitle(title: notebook.name)]
            newModel = Model(notebook: notebook, notes: model.notes)
        case .didDeleteNotebook:
            actions = [.finish]
        case let .didFailToAddNote(error):
            let errorMessage = error.error.localizedDescription
            updates = [.showError(error: "Failed to add note", message: errorMessage)]
        case let .didFailToDeleteNote(error):
            let errorMessage = error.error.localizedDescription
            let noteTitles = model.notes.map { $0.title }
            updates = [
                .updateAllNotes(notes: noteTitles),
                .showError(error: "Failed to delete notebook", message: errorMessage)
            ]
        case let .didFailToUpdateNotebook(error):
            let errorMessage = error.error.localizedDescription
            updates = [
                .updateTitle(title: model.notebook.name),
                .showError(error: "Failed to update notebook's title", message: errorMessage)
            ]
        case let .didFailToDeleteNotebook(error):
            let errorMessage = error.error.localizedDescription
            updates = [.showError(error: "Failed to delete notebook", message: errorMessage)]
        }

        return EvaluatorResult(updates: updates, actions: actions, model: newModel)
    }
}

private extension UI.Notebook {
    static func defaultNoteSorting(leftNote: Note, rightNote: Note) -> Bool {
        return leftNote.title < rightNote.title
    }
}
