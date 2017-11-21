//
//  Notebook.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

enum Notebook {
    struct Model: AutoEquatable {
        let meta: Meta
        let notes: [Note.Model]
        var uuid: String {
            return meta.uuid
        }
        var name: String {
            return meta.name
        }

        init(meta: Meta, notes: [Note.Model]) {
            self.meta = meta
            self.notes = notes
        }

        init(uuid: String, name: String, notes: [Note.Model]) {
            let meta = Meta(uuid: uuid, name: name)
            self.init(meta: meta, notes: notes)
        }
    }

    struct Meta: Codable, AutoEquatable {
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
        case addNote(note: Note.Model)
        case removeNote(note: Note.Model)
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
                let contentURL = newModel.noteContentURL(forNote: noteToAdd)
                let noteContent = Note.Content(content: noteToAdd.content)
                actions = [
                    .createFile(url: metaURL, content: noteToAdd.meta),
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

extension Notebook.Model {
    func notebookURL() -> URL {
        return URL(string: uuid)!.appendingPathExtension(Extension.notebook)
    }

    func noteBookMetaURL() -> URL {
        return notebookURL()
            .appendingPathComponent(Component.meta)
            .appendingPathExtension(Extension.json)
    }

    func noteURL(forNote note: Note.Model) -> URL {
        return notebookURL()
            .appendingPathComponent(note.uuid)
            .appendingPathExtension(Extension.note)
    }

    func noteMetaURL(forNote note: Note.Model) -> URL {
        return noteURL(forNote: note)
            .appendingPathComponent(Component.meta)
            .appendingPathExtension(Extension.json)
    }

    func noteContentURL(forNote note: Note.Model) -> URL {
        return noteURL(forNote: note)
            .appendingPathComponent(Component.content)
            .appendingPathExtension(Extension.json)
    }
}

// MARK: - Private

private extension Notebook.Model {
    func hasNote(withUUID noteUUID: String) -> Bool {
        return notes.filter({ $0.uuid == noteUUID }).count > 0
    }

    enum Extension {
        static let json = "json"
        static let note = "qvnote"
        static let notebook = "qvnotebook"
    }

    enum Component {
        static let meta = "meta"
        static let content = "content"
    }
}

// MARK: - Action Equtable
// TODO: Fix action type(similar to library) and replace this extension by autoequatable
extension Notebook.Action: Equatable {
    static func ==(lhs: Notebook.Action, rhs: Notebook.Action) -> Bool {
        switch (lhs, rhs) {
        case (.updateFile(let lURL, let lContent as Notebook.Meta),
              .updateFile(let rURL, let rContent as Notebook.Meta)):
            return (lURL == rURL) && (lContent == rContent)
        case (.createFile(let lURL, let lContent as Note.Meta),
              .createFile(let rURL, let rContent as Note.Meta)):
            return (lURL == rURL) && (lContent == rContent)
        case (.createFile(let lURL, let lContent as Note.Content),
              .createFile(let rURL, let rContent as Note.Content)):
            return (lURL == rURL) && (lContent == rContent)
        case (.deleteFile(let lURL), .deleteFile(let rURL)):
            return lURL == rURL
        default: return false
        }
    }
}