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
        let notes: [Note.Meta]
    }

    struct Meta: Codable, AutoEquatable, AutoLens {
        let uuid: String
        let name: String
        static let Unspecified = Meta(uuid: "unspecified", name: "")
    }

    enum Effect: AutoEquatable {
        case createNote(note: Note.Meta, url: URL)
        case updateNotebook(notebook: Meta, url: URL)
        case deleteNote(note: Note.Meta, url: URL)
        case readDirectory(atURL: URL)
        case readNotes(urls: [URL])
        case handleError(title: String, message: String)
        case didLoadNotes(notes: [Note.Meta])
    }

    enum Event {
        case loadNotes
        case changeName(newName: String)
        case addNote(note: Note.Meta)
        case removeNote(note: Note.Meta)
        case didReadDirectory(urls: Result<[URL], NSError>)
        case didReadNotes(notes: [Result<Note.Meta, AnyError>])
        case didAddNote(note: Note.Meta, error: Error?)
        case didDeleteNote(note: Note.Meta, error: Error?)
        case didUpdateNotebook(notebook: Meta, error: Error?)
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
                effects = [.updateNotebook(notebook: newModel.meta, url: url)]
            case let .addNote(noteToAdd):
                guard !model.hasNote(withUUID: noteToAdd.uuid) else { break }
                newModel = model |> Model.lens.notes .~ model.notes.appending(noteToAdd)
                let url = newModel.meta.noteMetaURL(for: noteToAdd)
                effects = [.createNote(note: noteToAdd, url: url)]
            case let .removeNote(noteToRemove):
                guard let indexOfRemovedNote = model.notes.index(of: noteToRemove) else { break }
                let notes = model.notes.removing(at: indexOfRemovedNote)
                newModel = model |> Model.lens.notes .~ notes
                let url = newModel.meta.noteURL(for: noteToRemove)
                effects = [.deleteNote(note: noteToRemove, url: url)]
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
            case let .didAddNote(note, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.notes .~ model.notes.removing(note)
            case let .didDeleteNote(note, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.notes .~ model.notes.appending(note)
            case let .didUpdateNotebook(notebook, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.meta.name .~ notebook.name
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
        return URL(string: meta.uuid)!.appendingPathExtension(Extension.notebook)
    }

    func noteBookMetaURL() -> URL {
        return notebookURL()
            .appendingPathComponent(Component.meta)
            .appendingPathExtension(Extension.json)
    }

    func noteURL(forNote note: Note.Model) -> URL {
        return notebookURL()
            .appendingPathComponent(note.meta.uuid)
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

extension Notebook.Meta {
    func notebookURL() -> URL {
        return URL(string: uuid)!.appendingPathExtension(Notebook.Model.Extension.notebook)
    }

    func noteURL(for note: Note.Meta) -> URL {
        return notebookURL()
            .appendingPathComponent(note.uuid)
            .appendingPathExtension(Notebook.Model.Extension.note)
    }

    func noteMetaURL(for note: Note.Meta) -> URL {
        return noteURL(for: note)
            .appendingPathComponent(Notebook.Model.Component.meta)
            .appendingPathExtension(Notebook.Model.Extension.json)
    }

    func noteContentURL(for note: Note.Meta) -> URL {
        return noteURL(for: note)
            .appendingPathComponent(Notebook.Model.Component.content)
            .appendingPathExtension(Notebook.Model.Extension.json)
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
