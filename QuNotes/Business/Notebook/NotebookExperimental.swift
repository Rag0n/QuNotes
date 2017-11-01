//
//  NotebookExperimental.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

extension Experimental {
    enum Notebook {}
}

extension Experimental.Notebook {
    struct Model: Codable {
        let uuid: String
        let name: String
        let notes: [Experimental.Note.Model]
    }

    enum Action {
        // TODO: content?
        case updateFile(url: URL)
        // TODO: content?
        case createFile(url: URL)
        case deleteFile(url: URL)
    }

    enum InputEvent {
        case changeName(newName: String)
        case addNote(note: Experimental.Note.Model)
        case removeNote(note: Experimental.Note.Model)
    }

    struct Evaluator {
        let actions: [Action]
        let model: Model

        init(model: Model) {
            self.model = model
            actions = []
        }

        func evaluate(event: InputEvent) -> Evaluator {
            var actions: [Action] = []
            var newModel = model

            switch event {
            case let .changeName(newName):
                newModel = Model(uuid: model.uuid, name: newName, notes: model.notes)
                let url = notebookURL(fromModel: newModel)
                actions = [.updateFile(url: url)]
            case let .addNote(noteToAdd):
                let notes = model.notes + [noteToAdd]
                newModel = Model(uuid: model.uuid, name: model.name, notes: notes)
                let url = noteURL(forNote: noteToAdd, model: newModel)
                actions = [.createFile(url: url)]
            case let .removeNote(noteToRemove):
                guard let indexOfRemovedNote = model.notes.index(of: noteToRemove) else { break }
                let notes = model.notes.removeWithoutMutation(at: indexOfRemovedNote)
                newModel = Model(uuid: model.uuid, name: model.name, notes: notes)
                let url = noteURL(forNote: noteToRemove, model: newModel)
                actions = [.deleteFile(url: url)]
            }

            return Evaluator(actions: actions, model: newModel)
        }

        fileprivate init(actions: [Action], model: Model) {
            self.actions = actions
            self.model = model
        }
    }
}

// MARK: - Private

private extension Experimental.Notebook {
    static func notebookURL(fromModel model: Model) -> URL {
        return URL(string: model.uuid)!.appendingPathExtension("qvnotebook")
    }

    static func noteURL(forNote note: Experimental.Note.Model, model: Model) -> URL {
        return notebookURL(fromModel: model)
            .appendingPathComponent(note.uuid)
            .appendingPathExtension("qvnote")
    }
}

// MARK: - Model equtable

extension Experimental.Notebook.Model: Equatable {
    static func ==(lhs: Experimental.Notebook.Model, rhs: Experimental.Notebook.Model) -> Bool {
        return (
            lhs.uuid == rhs.uuid &&
            lhs.name == rhs.name &&
            lhs.notes == rhs.notes
        )
    }
}

// MARK: - Action Equtable

extension Experimental.Notebook.Action: Equatable {}

func ==(lhs: Experimental.Notebook.Action, rhs: Experimental.Notebook.Action) -> Bool {
    switch (lhs, rhs) {
    case (.updateFile(let lURL), .updateFile(let rURL)):
        return lURL == rURL
    case (.createFile(let lURL), .createFile(let rURL)):
        return lURL == rURL
    case (.deleteFile(let lURL), .deleteFile(let rURL)):
        return lURL == rURL
    default: return false
    }
}
