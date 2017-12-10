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
    struct Model: AutoEquatable, AutoLens {
        let notebook: Notebook.Meta
        let notes: [Note.Meta]
    }

    enum Action: AutoEquatable {
        case addNote(note: Note.Meta)
        case showNote(note: Note.Meta, isNew: Bool)
        case deleteNote(note: Note.Meta)
        case deleteNotebook(notebook: Notebook.Meta)
        case updateNotebook(notebook: Notebook.Meta, title: String)
        case finish
        case showError(title: String, message: String)
    }

    enum ViewEffect: AutoEquatable {
        case updateAllNotes(notes: [String])
        case hideBackButton
        case showBackButton
        case updateTitle(title: String)
        case deleteNote(index: Int, notes: [String])
        case addNote(index: Int, notes: [String])
    }

    enum CoordinatorEvent {
        case didUpdateNotebook(notebook: Notebook.Meta, error: Error?)
        case didDeleteNotebook(error: Error?)
        case didLoadNotes(notes: [Note.Meta])
        case didAddNote(note: Note.Meta, error: Error?)
    }

    enum ViewEvent {
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
        let effects: [ViewEffect]
        let actions: [Action]
        let model: Model
        var generateUUID: () -> String = { UUID().uuidString }
        var currentTimestamp: () -> Double = { Date().timeIntervalSince1970 }

        init(notebook: Notebook.Meta) {
            effects = []
            actions = []
            model = Model(notebook: notebook, notes: [])
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
                effects = [.updateTitle(title: model.notebook.name)]
            case .addNote:
                let note = Note.Meta(uuid: generateUUID(), title: "", tags: [],
                                     updated_at: currentTimestamp(), created_at: currentTimestamp())
                newModel = model |> Model.lens.notes
                    .~ model.notes.appending(note).sorted(by: title)
                let indexOfNote = newModel.notes.index(of: note)!
                actions = [.addNote(note: note)]
                effects = [.addNote(index: indexOfNote, notes: titles(from: newModel))]
            case .selectNote(let index):
                let note = model.notes[index]
                actions = [.showNote(note: note, isNew: false)]
            case .deleteNote(let index):
                let note = model.notes[index]
                newModel = model |> Model.lens.notes .~ model.notes.removing(note)
                actions = [.deleteNote(note: note)]
            case .deleteNotebook:
                actions = [.deleteNotebook(notebook: model.notebook)]
            case let .filterNotes(filter):
                var filteredNotes = model.notes
                if let filter = filter?.lowercased() {
                    filteredNotes = model.notes.filter { $0.title.lowercased().contains(filter) }
                }
                effects = [.updateAllNotes(notes: titles(from: filteredNotes))]
            case .didStartToEditTitle:
                effects = [.hideBackButton]
            case .didFinishToEditTitle(let newTitle):
                effects = [.showBackButton]
                actions = [.updateNotebook(notebook: model.notebook, title: newTitle ?? "")]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel	)
        }

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case let .didUpdateNotebook(notebook, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.notebook .~ notebook
                effects = [.updateTitle(title: notebook.name)]
                actions = [.showError(title: "Failed to update notebook's title",
                                      message: error.localizedDescription)]
            case let .didDeleteNotebook(error):
                if let error = error {
                    actions = [.showError(title: "Failed to delete notebook", message: error.localizedDescription)]
                    break
                }
                actions = [.finish]
            case let .didLoadNotes(notes):
                newModel = model |> Model.lens.notes .~ notes.sorted(by: title)
                effects = [.updateAllNotes(notes: titles(from: newModel))]
            case let .didAddNote(note, error):
                guard let error = error else {
                    actions = [.showNote(note: note, isNew: true)]
                    break
                }
                newModel = model |> Model.lens.notes .~ model.notes.removing(note)
                actions = [.showError(title: "Failed to add note", message: error.localizedDescription)]
                let indexOfNote = model.notes.index(of: note)!
                effects = [.deleteNote(index: indexOfNote, notes: titles(from: newModel))]
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
                          additionalEffect: ViewEffect? = nil) -> Evaluator {
        let errorMessage = error.error.localizedDescription
        let actions: [Action] = [.showError(title: reason, message: errorMessage)]
        var effects: [ViewEffect] = []
        if let additionalEffect = additionalEffect {
            effects.append(additionalEffect)
        }

        return Evaluator(effects: effects,
                         actions: actions,
                         model: model)
    }

    static func titles(from model: Model) -> [String] {
        return titles(from: model.notes)
    }

    static func titles(from notes: [Note.Meta]) -> [String] {
        return notes.map { $0.title }
    }
}
