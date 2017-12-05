//
//  Notebook.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

enum Notebook {
    struct Model: AutoEquatable, AutoLens {
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

    struct Meta: Codable, AutoEquatable, AutoLens {
        let uuid: String
        let name: String
    }

    enum Effect {
        case updateFile(url: URL, content: Codable)
        case createFile(url: URL, content: Codable)
        case deleteFile(url: URL)
        case readDirectory(atURL: URL)
        case readNotes(urls: [URL])
        case handleError(title: String, message: String)
        case didLoadNotes(notes: [Note.Meta])
    }

    enum Event {
        case loadNotes
        case changeName(newName: String)
        case addNote(note: Note.Model)
        case removeNote(note: Note.Model)
        case didReadDirectory(urls: Result<[URL], NSError>)
        case didReadNotes(notes: [Result<Note.Meta, AnyError>])
    }

    struct Evaluator {
        let effects: [Effect]
        let model: Model

        init(model: Model) {
            self.model = model
            effects = []
        }

        func evaluate(event: Event) -> Evaluator {
            var effects: [Effect] = []
            var newModel = model

            switch event {
            case .loadNotes:
                effects = [.readDirectory(atURL: model.notebookURL())]
            case let .changeName(newName):
                newModel = model |> Model.lens.meta.name .~ newName
                let url = newModel.noteBookMetaURL()
                effects = [.updateFile(url: url, content: newModel.meta)]
            case let .addNote(noteToAdd):
                guard !model.hasNote(withUUID: noteToAdd.uuid) else { break }
                let notes = model.notes + [noteToAdd]
                newModel = model |> Model.lens.notes .~ notes
                let metaURL = newModel.noteMetaURL(forNote: noteToAdd)
                let contentURL = newModel.noteContentURL(forNote: noteToAdd)
                let noteContent = Note.Content(content: noteToAdd.content)
                effects = [
                    .createFile(url: metaURL, content: noteToAdd.meta),
                    .createFile(url: contentURL, content: noteContent),
                ]
            case let .removeNote(noteToRemove):
                guard let indexOfRemovedNote = model.notes.index(of: noteToRemove) else { break }
                let notes = model.notes.removing(at: indexOfRemovedNote)
                newModel = model |> Model.lens.notes .~ notes
                let url = newModel.noteURL(forNote: noteToRemove)
                effects = [.deleteFile(url: url)]
            case let .didReadDirectory(result):
                guard let urls = result.value else {
                    effects = [.handleError(title: "Failed to load notes",
                                            message: result.error!.localizedDescription)]
                    break
                }
                let notesURL = urls
                    .filter { $0.pathExtension == "qvnote" }
                    .map { $0.appendingPathComponent("meta").appendingPathExtension("json") }
                effects = [.readNotes(urls: notesURL)]
            case let .didReadNotes(result):
                let errors = result.filter { $0.error != nil }
                guard errors.count == 0 else {
                    var errorMessage = errors.reduce("") { $0 + $1.error!.localizedDescription + "\n" }
                    errorMessage = String(errorMessage.dropLast(1))
                    effects = [.handleError(title: "Unable to load notes", message: errorMessage)]
                    break
                }
                let notes = result.map { $0.value! }
                effects = [.didLoadNotes(notes: notes)]
            }

            return Evaluator(effects: effects, model: newModel)
        }

        fileprivate init(effects: [Effect], model: Model) {
            self.effects = effects
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

// MARK: - Effect Equtable
// TODO: Fix action type(similar to library) and replace this extension by autoequatable
extension Notebook.Effect: Equatable {
    static func ==(lhs: Notebook.Effect, rhs: Notebook.Effect) -> Bool {
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
        case (.readDirectory(let lURL), .readDirectory(let rURL)):
            return lURL == rURL
        case (.readNotes(let lURL), .readNotes(let rURL)):
            return lURL == rURL
        case let (.handleError(lTitle, lMessage), .handleError(rTitle, rMessage)):
            return (lTitle == rTitle) && (lMessage == rMessage)
        case let (.didLoadNotes(lNotes), .didLoadNotes(rNotes)):
            return lNotes == rNotes
        default: return false
        }
    }
}
