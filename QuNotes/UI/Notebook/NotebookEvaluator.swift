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
        case addNote(note: Note.Model)
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
    }

    enum CoordinatorEvent {
        case didUpdateNotebook(result: Result<Notebook.Meta, AnyError>)
        case didDeleteNotebook(error: AnyError?)
        case didLoadNotes(notes: [Note.Meta])
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
                let note = Note.Model(uuid: generateUUID(), title: "", content: "", tags: [], notebook: nil,
                                      updatedDate: currentTimestamp(), createdDate: currentTimestamp())
                newModel = model |> Model.lens.notes
                    .~ model.notes.appending(note.meta).sorted(by: title)
                actions = [
                    .addNote(note: note),
                    .showNote(note: note.meta, isNew: true)
                ]
            case .selectNote(let index):
                let note = model.notes[index]
                actions = [.showNote(note: note, isNew: false)]
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
            case let .didUpdateNotebook(result):
                guard case let .success(notebook) = result else {
                    let additionalEffect: ViewEffect = .updateTitle(title: model.notebook.name)
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
                newModel = model |> Model.lens.notes .~ notes.sorted(by: title)
                effects = [.updateAllNotes(notes: titles(from: newModel))]
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
