//
//  NotebookEvaluator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 11.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result
import Prelude
import Core

extension Notebook {
    struct Evaluator {
        let effects: [ViewEffect]
        let actions: [Action]
        let model: Model
        var generateUUID: () -> String = { UUID().uuidString }
        var currentTimestamp: () -> Double = { Date().timeIntervalSince1970 }

        init(notebook: Core.Notebook.Meta) {
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
                effects = [.updateTitle(model.notebook.name)]
            case .addNote:
                let note = Core.Note.Meta(uuid: generateUUID(), title: "", tags: [],
                                     updated_at: currentTimestamp(), created_at: currentTimestamp())
                newModel = model |> Model.lens.notes
                    .~ model.notes.appending(note).sorted(by: title)
                let indexOfNote = newModel.notes.index(of: note)!
                actions = [.addNote(note)]
                // TODO: What if we have filter?
                effects = [.addNote(index: indexOfNote, notes: titles(from: newModel))]
            case .selectNote(let index):
                let note = model.notes[index]
                actions = [.showNote(note, isNew: false)]
            case .deleteNote(let index):
                let note = model.notes[index]
                newModel = model |> Model.lens.notes .~ model.notes.removing(note)
                actions = [.deleteNote(note)]
            case .deleteNotebook:
                actions = [.deleteNotebook(model.notebook)]
            case let .filterNotes(filter):
                var filteredNotes = model.notes
                if let filter = filter?.lowercased() {
                    filteredNotes = model.notes.filter { $0.title.lowercased().contains(filter) }
                }
                // TODO: This event is not working correctly. Eg: filter notes, then select note. Indexes will differ because here we store all notes and in UI we pass only filtered notes
                effects = [.updateAllNotes(titles(from: filteredNotes))]
            case .didStartToEditTitle:
                effects = [.hideBackButton]
            case .didFinishToEditTitle(let newTitle):
                effects = [.showBackButton]
                actions = [.updateNotebook(model.notebook, title: newTitle ?? "")]
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
                effects = [.updateTitle(notebook.name)]
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
                // TODO: what if we have filter
                effects = [.updateAllNotes(titles(from: newModel))]
            case let .didAddNote(note, error):
                guard let error = error else {
                    actions = [.showNote(note, isNew: true)]
                    break
                }
                newModel = model |> Model.lens.notes .~ model.notes.removing(note)
                actions = [.showError(title: "Failed to add note", message: error.localizedDescription)]
                let indexOfNote = model.notes.index(of: note)!
                effects = [.deleteNote(index: indexOfNote, notes: titles(from: newModel))]
            case let .didDeleteNote(note, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.notes
                    .~ model.notes.appending(note).sorted(by: title)
                actions = [.showError(title: "Failed to delete note", message: error.localizedDescription)]
                let indexOfNote = newModel.notes.index(of: note)!
                effects = [.addNote(index: indexOfNote, notes: titles(from: newModel))]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}

// MARK: - Private

private extension Notebook {
    static func title(lhs: Core.Note.Meta, rhs: Core.Note.Meta) -> Bool {
        return lhs.title.lowercased() < rhs.title.lowercased()
    }

    static func titles(from model: Model) -> [String] {
        return titles(from: model.notes)
    }

    static func titles(from notes: [Core.Note.Meta]) -> [String] {
        return notes.map { $0.title }
    }
}
