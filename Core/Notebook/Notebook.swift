//
//  Notebook.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result
import Prelude

public enum Notebook {
    public struct Model: AutoEquatable, AutoLens {
        public let meta: Meta
        public let notes: [Note.Meta]

        public init(meta: Meta, notes: [Note.Meta]) {
            self.meta = meta
            self.notes = notes
        }
    }

    public struct Meta: Codable, AutoEquatable, AutoLens {
        public let uuid: String
        public let name: String
        public static let Unspecified = Meta(uuid: "unspecified", name: "")

        public init(uuid: String, name: String) {
            self.uuid = uuid
            self.name = name
        }
    }

    public enum Effect: AutoEquatable {
        case createNote(Note.Meta, url: DynamicBaseURL, content: Note.Content, contentURL: DynamicBaseURL)
        case updateNotebook(Meta, url: DynamicBaseURL)
        case deleteNote(Note.Meta, url: DynamicBaseURL)
        case readDirectory(atURL: DynamicBaseURL)
        case readNotes(urls: [URL])
        case handleError(title: String, message: String)
        case didLoadNotes([Note.Meta])
        case removeDirectory(url: DynamicBaseURL)
    }

    public enum Event {
        case loadNotes
        case changeName(String)
        case addNote(Note.Meta)
        case removeNote(Note.Meta)
        case didReadDirectory(urls: Result<[URL], NSError>)
        case didReadNotes([Result<Note.Meta, AnyError>])
        case didAddNote(Note.Meta, error: Error?)
        case didDeleteNote(Note.Meta, error: Error?)
        case didUpdateNotebook(Meta, error: Error?)
    }

    public struct Evaluator {
        public let effects: [Effect]
        public let model: Model

        public init(model: Model) {
            self.model = model
            effects = []
        }

        public func evaluate(event: Event) -> Evaluator {
            var effects: [Effect] = []
            var newModel = model

            switch event {
            case .loadNotes:
                effects = [.readDirectory(atURL: model.meta.notebookURL())]
            case let .changeName(newName):
                newModel = model |> Model.lens.meta.name .~ newName
                let url = newModel.meta.metaURL()
                effects = [.updateNotebook(newModel.meta, url: url)]
            case let .addNote(noteToAdd):
                guard !model.hasNote(withUUID: noteToAdd.uuid) else { break }
                newModel = model |> Model.lens.notes .~ model.notes.appending(noteToAdd)
                let url = newModel.meta.noteMetaURL(for: noteToAdd)
                let content = Note.Content(title: noteToAdd.title, cells: [])
                let contentURL = newModel.meta.noteContentURL(for: noteToAdd)
                effects = [.createNote(noteToAdd, url: url, content: content, contentURL: contentURL)]
            case let .removeNote(noteToRemove):
                guard let indexOfRemovedNote = model.notes.index(of: noteToRemove) else { break }
                let notes = model.notes.removing(at: indexOfRemovedNote)
                newModel = model |> Model.lens.notes .~ notes
                let url = newModel.meta.noteURL(for: noteToRemove)
                effects = [.deleteNote(noteToRemove, url: url)]
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
                newModel = model |> Model.lens.notes .~ notes
                effects = [.didLoadNotes(notes)]
            case let .didAddNote(note, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.notes .~ model.notes.removing(note)
                effects = [.removeDirectory(url: newModel.meta.noteURL(for: note))]
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

// MARK: Meta API
extension Notebook.Meta {
    private var notebookPlainURL: URL {
        return URL(string: uuid)!
            .appendingPathExtension(Extension.notebook)
    }

    private func notePlainURL(for note: Note.Meta) -> URL {
        return notebookPlainURL
            .appendingPathComponent(note.uuid)
            .appendingPathExtension(Extension.note)
    }

    func noteURL(for note: Note.Meta) -> DynamicBaseURL {
        return notebookPlainURL
            .appendingPathComponent(note.uuid)
            .appendingPathExtension(Extension.note)
            |> DynamicBaseURL.init
    }

    func notebookURL() -> DynamicBaseURL {
        return notebookPlainURL |> DynamicBaseURL.init
    }

    func metaURL() -> DynamicBaseURL {
        return notebookPlainURL
            .appendingPathComponent(Component.meta)
            .appendingPathExtension(Extension.json)
            |> DynamicBaseURL.init
    }

    func noteMetaURL(for note: Note.Meta) -> DynamicBaseURL {
        return notePlainURL(for: note)
            .appendingPathComponent(Component.meta)
            .appendingPathExtension(Extension.json)
            |> DynamicBaseURL.init
    }

    func noteContentURL(for note: Note.Meta) -> DynamicBaseURL {
        return notePlainURL(for: note)
            .appendingPathComponent(Component.content)
            .appendingPathExtension(Extension.json)
            |> DynamicBaseURL.init
    }
}

// MARK: - Private

private extension Notebook.Model {
    func hasNote(withUUID noteUUID: String) -> Bool {
        return notes.filter({ $0.uuid == noteUUID }).count > 0
    }
}

private extension Notebook.Meta {
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
