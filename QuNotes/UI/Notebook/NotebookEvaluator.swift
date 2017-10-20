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
    struct Model {
        let notebook: Notebook
        let notes: [Note]
    }

    enum Action {
        case addNote
        case showNote(note: Note)
        case deleteNote(note: Note)
        case deleteNotebook(notebook: Notebook)
        case updateNotebook(notebook: Notebook, title: String)
        case finish
    }

    enum ViewControllerEffect {
        case updateAllNotes(notes: [String])
        case hideBackButton
        case showBackButton
        case updateTitle(title: String)
        case deleteNote(index: Int, notes: [String])
        case showError(error: String, message: String)
    }

    enum CoordinatorEvent {
        case didUpdateNotes(notes: [Note])
        case didAddNote(note: Note)
        case didDeleteNote(note: Note)
        case didUpdateNotebook(notebook: Notebook)
        case didDeleteNotebook
        case didFailToAddNote(error: AnyError)
        case didFailToDeleteNote(error: AnyError)
        case didFailToUpdateNotebook(error: AnyError)
        case didFailToDeleteNotebook(error: AnyError)
    }

    enum ViewControllerEvent {
        case addNote
        case selectNote(index: Int)
        case deleteNote(index: Int)
        case deleteNotebook
        case filterNotes(filter: String?)
        case didStartToEditTitle
        case didFinishToEditTitle(newTitle: String?)
    }

    // MARK: - Evaluator

    struct Evaluator {
        let effects: [ViewControllerEffect]
        let actions: [Action]
        let model: Model

        init(withNotebook notebook: Notebook) {
            effects = []
            actions = []
            model = Model(notebook: notebook, notes: [])
        }

        private init(effects: [ViewControllerEffect], actions: [Action], model: Model) {
            self.effects = effects
            self.actions = actions
            self.model = model
        }

        func evaluate(event: ViewControllerEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewControllerEffect] = []

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
                effects = [.updateAllNotes(notes: noteTitles)]
            case .didStartToEditTitle:
                effects = [.hideBackButton]
            case .didFinishToEditTitle(let newTitle):
                effects = [.showBackButton]
                actions = [.updateNotebook(notebook: model.notebook, title: newTitle ?? "")]
            }

            return Evaluator(effects: effects, actions: actions, model: model)
        }

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewControllerEffect] = []
            var newModel = model

            switch event {
            case let .didUpdateNotes(notes):
                let sortedNotes = notes.sorted(by: defaultNoteSorting)
                let noteTitles = sortedNotes.map { $0.title }
                effects = [.updateAllNotes(notes: noteTitles)]
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
                effects = [.deleteNote(index: indexOfDeletedNote, notes: noteTitles)]
                newModel = Model(notebook: model.notebook, notes: updatedNotes)
            case let .didUpdateNotebook(notebook):
                effects = [.updateTitle(title: notebook.name)]
                newModel = Model(notebook: notebook, notes: model.notes)
            case .didDeleteNotebook:
                actions = [.finish]
            case let .didFailToAddNote(error):
                let errorMessage = error.error.localizedDescription
                effects = [.showError(error: "Failed to add note", message: errorMessage)]
            case let .didFailToDeleteNote(error):
                let errorMessage = error.error.localizedDescription
                let noteTitles = model.notes.map { $0.title }
                effects = [
                    .updateAllNotes(notes: noteTitles),
                    .showError(error: "Failed to delete notebook", message: errorMessage)
                ]
            case let .didFailToUpdateNotebook(error):
                let errorMessage = error.error.localizedDescription
                effects = [
                    .updateTitle(title: model.notebook.name),
                    .showError(error: "Failed to update notebook's title", message: errorMessage)
                ]
            case let .didFailToDeleteNotebook(error):
                let errorMessage = error.error.localizedDescription
                effects = [.showError(error: "Failed to delete notebook", message: errorMessage)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}

private extension UI.Notebook {
    static func defaultNoteSorting(leftNote: Note, rightNote: Note) -> Bool {
        return leftNote.title < rightNote.title
    }
}
