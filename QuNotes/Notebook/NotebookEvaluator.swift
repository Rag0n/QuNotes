//
//  NotebookEvaluator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 11.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Prelude
import Core

extension Notebook {
    struct Evaluator {
        let effects: [ViewEffect]
        let actions: [Action]
        let model: Model
        var generateUUID: () -> String = { UUID().uuidString }
        var currentTimestamp: () -> Double = { Date().timeIntervalSince1970 }

        init(notebook: Core.Notebook.Meta, isNew: Bool) {
            effects = []
            actions = []
            model = Model(notebook: notebook, notes: [], filter: "", isNew: isNew)
        }

        fileprivate init(effects: [ViewEffect], actions: [Action], model: Model) {
            self.effects = effects
            self.actions = actions
            self.model = model
        }

        func evaluating(event: ViewEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case .didLoad:
                effects = [.updateTitle(model.notebook.name)]
                if model.isNew {
                    effects += [.focusOnTitle]
                }
            case .addNote:
                let note = newNote()
                newModel = model |> Model.lens.notes
                    .~ model.notes.appending(note).sorted(by: title)
                actions = [.addNote(note)]
                effects = [.addNote(index: newModel.notes.index(of: note)!,
                                    notes: viewModels(from: newModel))]
            case let .selectNote(index):
                let note = model.filteredNotes[index]
                actions = [.showNote(note, isNew: false)]
            case let .deleteNote(index):
                let note = model.notes[index]
                newModel = model |> Model.lens.notes .~ model.notes.removing(note)
                actions = [.deleteNote(note)]
                effects = [.deleteNote(index: index, notes: viewModels(from: newModel))]
            case .deleteNotebook:
                actions = [.deleteNotebook]
            case let .filterNotes(filter):
                let lowercasedFilter = filter?.lowercased() ?? ""
                newModel = model |> Model.lens.filter .~ lowercasedFilter
                effects = [.updateAllNotes(viewModels(from: newModel))]
            case .didStartToEditTitle:
                effects = [.hideBackButton]
            case let .didFinishToEditTitle(newTitle):
                effects = [.showBackButton]
                actions = [.updateNotebook(title: newTitle ?? "")]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }

        func evaluating(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case let .updateNote(note):
                guard let index = model.index(ofNote: note) else { break }
                newModel = model |> Model.lens.notes .~
                    model.notes.replacing(at: index, new: note).sorted(by: title)
                effects = [.updateAllNotes(viewModels(from: newModel))]
            case let .deleteNote(note):
                guard let index = model.index(ofNote: note) else { break }
                newModel = model |> Model.lens.notes .~ model.notes.removing(at: index)
                actions = [.deleteNote(model.notes[index])]
                effects = [.deleteNote(index: index, notes: viewModels(from: newModel))]
            case let .didUpdateNotebook(oldNotebook, notebook, error):
                guard let error = error else {
                    actions = [.didUpdateNotebook(notebook)]
                    break
                }
                newModel = model |> Model.lens.notebook .~ oldNotebook
                effects = [.updateTitle(oldNotebook.name)]
                actions = [.showFailure(.updateNotebook, reason: error.localizedDescription)]
            case let .didDeleteNotebook(error):
                if let error = error {
                    actions = [.showFailure(.deleteNotebook, reason: error.localizedDescription)]
                    break
                }
                actions = [.finish]
            case let .didLoadNotes(notes):
                newModel = model |> Model.lens.notes .~ notes.sorted(by: title)
                effects = [.updateAllNotes(viewModels(from: newModel))]
            case let .didAddNote(note, error):
                guard let error = error else {
                    actions = [.showNote(note, isNew: true)]
                    break
                }
                newModel = model |> Model.lens.notes .~ model.notes.removing(note)
                actions = [.showFailure(.addNote, reason: error.localizedDescription)]
                effects = [.deleteNote(index: model.notes.index(of: note)!,
                                       notes: viewModels(from: newModel))]
            case let .didDeleteNote(note, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.notes
                    .~ model.notes.appending(note).sorted(by: title)
                actions = [.showFailure(.deleteNote, reason: error.localizedDescription)]
                effects = [.addNote(index: newModel.notes.index(of: note)!,
                                    notes: viewModels(from: newModel))]
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

    static func viewModels(from model: Model) -> [NoteViewModel] {
//        let tags = model.notes.map { $0.tags.joined(separator: " ") }
//        return NoteViewModel(title: model.note)
        return model.filteredNotes.map { NoteViewModel(title: $0.title) }
    }
}

private extension Notebook.Model {
    var filteredNotes: [Core.Note.Meta] {
        guard filter.count != 0 else { return notes }
        return notes.filter { $0.title.lowercased().contains(filter) }
    }

    func index(ofNote note: Core.Note.Meta) -> Array<Core.Note.Meta>.Index? {
        return notes.index { $0.uuid == note.uuid }
    }
}

private extension Notebook.Evaluator {
    func newNote() -> Core.Note.Meta {
        let time = currentTimestamp()
        return Core.Note.Meta(uuid: generateUUID(), title: "", tags: [], updated_at: time, created_at: time)
    }
}
