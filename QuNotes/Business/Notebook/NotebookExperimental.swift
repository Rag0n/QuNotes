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
    struct Model {
        let meta: Meta
        let notes: [Experimental.Note.Model]
        var uuid: String {
            return meta.uuid
        }
        var name: String {
            return meta.name
        }

        init(uuid: String, name: String, notes: [Experimental.Note.Model]) {
            self.meta = Meta(uuid: uuid, name: name)
            self.notes = notes
        }

        init(meta: Meta, notes: [Experimental.Note.Model]) {
            self.meta = meta
            self.notes = notes
        }
    }

    struct Meta: Codable {
        let uuid: String
        let name: String
    }

    enum Action {
        case updateFile(url: URL, content: Codable)
        case createFile(url: URL, content: Codable)
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
                let url = newModel.noteBookMetaURL()
                actions = [.updateFile(url: url, content: newModel.meta)]
            case let .addNote(noteToAdd):
                guard !model.hasNote(withUUID: noteToAdd.uuid) else { break }
                let notes = model.notes + [noteToAdd]
                newModel = Model(uuid: model.uuid, name: model.name, notes: notes)
                let metaURL = newModel.noteMetaURL(forNote: noteToAdd)
                let noteMeta = Experimental.Note.Meta(model: noteToAdd)
                let contentURL = newModel.noteContentURL(forNote: noteToAdd)
                let noteContent = Experimental.Note.Content(content: noteToAdd.content)
                actions = [
                    .createFile(url: metaURL, content: noteMeta),
                    .createFile(url: contentURL, content: noteContent),
                ]
            case let .removeNote(noteToRemove):
                guard let indexOfRemovedNote = model.notes.index(of: noteToRemove) else { break }
                let notes = model.notes.removeWithoutMutation(at: indexOfRemovedNote)
                newModel = Model(uuid: model.uuid, name: model.name, notes: notes)
                let url = newModel.noteURL(forNote: noteToRemove)
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

// MARK: Model API

extension Experimental.Notebook.Model {
    func notebookURL() -> URL {
        return URL(string: uuid)!.appendingPathExtension("qvnotebook")
    }

    func noteBookMetaURL() -> URL {
        return notebookURL()
            .appendingPathComponent("meta")
            .appendingPathExtension("json")
    }

    func noteURL(forNote note: Experimental.Note.Model) -> URL {
        return notebookURL()
            .appendingPathComponent(note.uuid)
            .appendingPathExtension("qvnote")
    }

    func noteMetaURL(forNote note: Experimental.Note.Model) -> URL {
        return noteURL(forNote: note)
            .appendingPathComponent("meta")
            .appendingPathExtension("json")
    }

    func noteContentURL(forNote note: Experimental.Note.Model) -> URL {
        return noteURL(forNote: note)
            .appendingPathComponent("content")
            .appendingPathExtension("json")
    }
}

// MARK: - Private

private extension Experimental.Notebook.Model {
    func hasNote(withUUID noteUUID: String) -> Bool {
        return notes.filter({ $0.uuid == noteUUID }).count > 0
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

// MARK: Meta equtable

extension Experimental.Notebook.Meta: Equatable {
    static func ==(lhs: Experimental.Notebook.Meta, rhs: Experimental.Notebook.Meta) -> Bool {
        return (
            lhs.uuid == rhs.uuid &&
            lhs.name == rhs.name
        )
    }
}


// MARK: - Action Equtable

extension Experimental.Notebook.Action: Equatable {
    static func ==(lhs: Experimental.Notebook.Action, rhs: Experimental.Notebook.Action) -> Bool {
        switch (lhs, rhs) {
        case (.updateFile(let lURL, let lContent as Experimental.Notebook.Meta),
              .updateFile(let rURL, let rContent as Experimental.Notebook.Meta)):
            return (lURL == rURL) && (lContent == rContent)
        case (.createFile(let lURL, let lContent as Experimental.Note.Meta),
              .createFile(let rURL, let rContent as Experimental.Note.Meta)):
            return (lURL == rURL) && (lContent == rContent)
        case (.createFile(let lURL, let lContent as Experimental.Note.Content),
              .createFile(let rURL, let rContent as Experimental.Note.Content)):
            return (lURL == rURL) && (lContent == rContent)
        case (.deleteFile(let lURL), .deleteFile(let rURL)):
            return lURL == rURL
        default: return false
        }
    }
}
