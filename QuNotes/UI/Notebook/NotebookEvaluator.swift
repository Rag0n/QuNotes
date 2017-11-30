//
//  NotebookEvaluator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 11.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

extension UI {
    enum Notebook {}
}

extension UI.Notebook {
    struct Model: AutoEquatable {
        let notebook: Notebook.Meta
        let notes: [Note.Meta]
    }

    enum Action: AutoEquatable {
        case addNote
        case showNote(note: Note.Meta, isNewNote: Bool)
        case deleteNote(note: Note.Meta)
        case deleteNotebook(notebook: Notebook.Meta)
        case updateNotebook(notebook: Notebook.Meta, title: String)
        case finish
        case showError(title: String, message: String)
    }

    enum ViewControllerEffect: AutoEquatable {
        case updateAllNotes(notes: [String])
        case hideBackButton
        case showBackButton
        case updateTitle(title: String)
        case deleteNote(index: Int, notes: [String])
    }

    enum CoordinatorEvent {
        case didUpdateNotes(notes: [UseCase.Note])
        case didAddNote(result: Result<UseCase.Note, AnyError>)
        case didDeleteNote(result: Result<UseCase.Note, AnyError>)
        case didUpdateNotebook(result: Result<Notebook.Meta, AnyError>)
        case didDeleteNotebook(error: AnyError?)
        case didLoadNotes(notes: [Note.Meta])
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

        init(notebook: Notebook.Meta) {
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
            case let .filterNotes(filter):
                let lowercasedFilter = filter?.lowercased()
                var filteredNotes = model.notes
                if let filter = lowercasedFilter {
                    filteredNotes = model.notes.filter { $0.title.lowercased().contains(filter) }
                }
                effects = [.updateAllNotes(notes: noteTitles(from: filteredNotes))]
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
//                let sortedNotes = notes.sorted(by: defaultNoteSorting)
//                let noteTitles = sortedNotes.map { $0.title }
//                effects = [.updateAllNotes(notes: noteTitles)]
//                newModel = Model(notebook: model.notebook, notes: sortedNotes)
                break
            case let .didAddNote(result):
                guard case let .success(note) = result else {
                    return showError(error: result.error!,
                                     reason: "Failed to add note",
                                     model: model)
                }

//                let newNotes = model.notes + [note]
//                let sortedNotes = newNotes.sorted(by: defaultNoteSorting)
//                newModel = Model(notebook: model.notebook, notes: sortedNotes)
//                actions = [.showNote(note: note, isNewNote: true)]
            case let .didDeleteNote(result):
                guard case let .success(note) = result else {
                    let noteTitles = model.notes.map { $0.title }
                    let additionalEffect: ViewControllerEffect = .updateAllNotes(notes: noteTitles)
                    return showError(error: result.error!,
                                     reason: "Failed to delete notebook",
                                     model: model,
                                     additionalEffect: additionalEffect)
                }

//                let indexOfDeletedNote = model.notes.index(of: note)!
//                let updatedNotes = model.notes.removeWithoutMutation(at: indexOfDeletedNote)
//                let noteTitles = updatedNotes.map { $0.title }
//                effects = [.deleteNote(index: indexOfDeletedNote, notes: noteTitles)]
//                newModel = Model(notebook: model.notebook, notes: updatedNotes)
            case let .didUpdateNotebook(result):
                guard case let .success(notebook) = result else {
                    let additionalEffect: ViewControllerEffect = .updateTitle(title: model.notebook.name)
                    return showError(error: result.error!,
                                     reason: "Failed to update notebook's title",
                                     model: model,
                                     additionalEffect: additionalEffect)
                }

                effects = [.updateTitle(title: notebook.name)]
//                newModel = Model(notebook: notebook, notes: model.notes)
            case let .didDeleteNotebook(error):
                guard error == nil else {
                    return showError(error: error!,
                                     reason: "Failed to delete notebook",
                                     model: model)
                }

                actions = [.finish]
            case let .didLoadNotes(notes):
                let sortedNotes = notes.sorted(by: title)
                newModel = Model(notebook: model.notebook, notes: sortedNotes)
                effects = [.updateAllNotes(notes: noteTitles(from: sortedNotes))]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}

// MARK: - Private

private extension UI.Notebook {
    static func title(lhs: Note.Meta, rhs: Note.Meta) -> Bool {
        return lhs.title.lowercased() < rhs.title.lowercased()
    }

    static func showError(error: AnyError,
                          reason: String,
                          model: Model,
                          additionalEffect: ViewControllerEffect? = nil) -> Evaluator {
        let errorMessage = error.error.localizedDescription
        let actions: [Action] = [.showError(title: reason, message: errorMessage)]
        var effects: [ViewControllerEffect] = []
        if let additionalEffect = additionalEffect {
            effects.append(additionalEffect)
        }

        return Evaluator(effects: effects,
                         actions: actions,
                         model: model)
    }

    static func noteTitles(from notes: [Note.Meta]) -> [String] {
        return notes.map { $0.title }
    }
}
