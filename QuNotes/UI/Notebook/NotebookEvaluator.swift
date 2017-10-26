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
        case showNote(note: Note, isNewNote: Bool)
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
        case didAddNote(result: Result<Note, AnyError>)
        case didDeleteNote(result: Result<Note, AnyError>)
        case didUpdateNotebook(result: Result<Notebook, AnyError>)
        case didDeleteNotebook(error: AnyError?)
    }

    enum ViewControllerEvent {
        case didLoad
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

        fileprivate init(effects: [ViewControllerEffect], actions: [Action], model: Model) {
            self.effects = effects
            self.actions = actions
            self.model = model
        }

        func evaluate(event: ViewControllerEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewControllerEffect] = []

            switch event {
            case .didLoad:
                effects = [.updateTitle(title: model.notebook.name)]
            case .addNote:
                actions = [.addNote]
            case .selectNote(let index):
                let note = model.notes[index]
                actions = [.showNote(note: note, isNewNote: false)]
            case .deleteNote(let index):
                let note = model.notes[index]
                actions = [.deleteNote(note: note)]
            case .deleteNotebook:
                actions = [.deleteNotebook(notebook: model.notebook)]
            case .filterNotes(let filter):
                let lowercasedFilter = filter?.lowercased()
                var filteredNotes = model.notes
                if let filter = lowercasedFilter {
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
            case let .didAddNote(result):
                guard case let .success(note) = result else {
                    return showError(error: result.error!,
                                     reason: "Failed to add note",
                                     model: model)
                }

                let newNotes = model.notes + [note]
                let sortedNotes = newNotes.sorted(by: defaultNoteSorting)
                newModel = Model(notebook: model.notebook, notes: sortedNotes)
                actions = [.showNote(note: note, isNewNote: true)]
            case let .didDeleteNote(result):
                guard case let .success(note) = result else {
                    let noteTitles = model.notes.map { $0.title }
                    let additionalEffect: ViewControllerEffect = .updateAllNotes(notes: noteTitles)
                    return showError(error: result.error!,
                                     reason: "Failed to delete notebook",
                                     model: model,
                                     additionalEffect: additionalEffect)
                }

                let indexOfDeletedNote = model.notes.index(of: note)!
                let updatedNotes = model.notes.removeWithoutMutation(at: indexOfDeletedNote)
                let noteTitles = updatedNotes.map { $0.title }
                effects = [.deleteNote(index: indexOfDeletedNote, notes: noteTitles)]
                newModel = Model(notebook: model.notebook, notes: updatedNotes)
            case let .didUpdateNotebook(result):
                guard case let .success(notebook) = result else {
                    let additionalEffect: ViewControllerEffect = .updateTitle(title: model.notebook.name)
                    return showError(error: result.error!,
                                     reason: "Failed to update notebook's title",
                                     model: model,
                                     additionalEffect: additionalEffect)
                }

                effects = [.updateTitle(title: notebook.name)]
                newModel = Model(notebook: notebook, notes: model.notes)
            case let .didDeleteNotebook(error):
                guard error == nil else {
                    return showError(error: error!,
                                     reason: "Failed to delete notebook",
                                     model: model)
                }

                actions = [.finish]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}

// MARK: - Private

private extension UI.Notebook {
    static func defaultNoteSorting(leftNote: Note, rightNote: Note) -> Bool {
        return leftNote.title.lowercased() < rightNote.title.lowercased()
    }

    static func showError(error: AnyError,
                          reason: String,
                          model: Model,
                          additionalEffect: ViewControllerEffect? = nil) -> Evaluator {
        let errorMessage = error.error.localizedDescription
        var effects: [ViewControllerEffect] = [
            .showError(error: reason, message: errorMessage)
        ]
        if let additionalEffect = additionalEffect {
            effects.insert(additionalEffect, at: 0)
        }

        return Evaluator(effects: effects,
                         actions: [],
                         model: model)
    }
}

// MARK: - ViewControllerEffect Equatable

extension UI.Notebook.ViewControllerEffect: Equatable {}

func ==(lhs: UI.Notebook.ViewControllerEffect, rhs: UI.Notebook.ViewControllerEffect) -> Bool {
    switch (lhs, rhs) {
    case (.updateAllNotes(let lNotes), .updateAllNotes(let rNotes)):
        return lNotes == rNotes
    case (.hideBackButton, .hideBackButton):
        return true
    case (.showBackButton, .showBackButton):
        return true
    case (.updateTitle(let lTitle), .updateTitle(let rTitle)):
        return lTitle == rTitle
    case (.deleteNote(let lIndex, let lNotes), .deleteNote(let rIndex, let rNotes)):
        return (lIndex == rIndex) && (lNotes == rNotes)
    case (.showError(let lError, let lMessage), .showError(let rError, let rMessage)):
        return (lError == rError) && (lMessage == rMessage)
    default: return false
    }
}

// MARK: - Action Equtable

extension UI.Notebook.Action: Equatable {}

func ==(lhs: UI.Notebook.Action, rhs: UI.Notebook.Action) -> Bool {
    switch (lhs, rhs) {
    case (.addNote, .addNote):
        return true
    case (.showNote(let lNote), .showNote(let rNote)):
        return lNote == rNote
    case (.deleteNote(let lNote), .deleteNote(let rNote)):
        return lNote == rNote
    case (.deleteNotebook(let lNotebook), .deleteNotebook(let rNotebook)):
        return lNotebook == rNotebook
    case (.updateNotebook(let lNotebook), .updateNotebook(let rNotebook)):
        return lNotebook == rNotebook
    case (.finish, .finish):
        return true
    default: return false
    }
}
