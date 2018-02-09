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
        case updateNotebook(Meta, url: DynamicBaseURL, oldNotebook: Meta)
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
        case didReadDirectory(urls: Result<[URL], AnyError>)
        case didReadNotes([Result<Note.Meta, AnyError>])
        case didAddNote(Note.Meta, error: Error?)
        case didDeleteNote(Note.Meta, error: Error?)
        case didUpdateNotebook(oldNotebook: Meta, error: Error?)
    }

    public struct Evaluator {
        public let effects: [Effect]
        public let model: Model

        public init(model: Model) {
            self.model = model
            effects = []
        }

        public func evaluating(event: Event) -> Evaluator {
            var effects: [Effect] = []
            var newModel = model

            switch event {
            case .loadNotes:
                effects = [.readDirectory(atURL: model.meta.notebookURL())]
            case let .changeName(newName):
                newModel = model |> Model.lens.meta.name .~ newName
                effects = [.updateNotebook(newModel.meta, url: newModel.meta.metaURL(), oldNotebook: model.meta)]
            case let .addNote(noteToAdd):
                guard !model.hasNote(withUUID: noteToAdd.uuid) else { break }
                newModel = model |> Model.lens.notes .~ model.notes.appending(noteToAdd)
                effects = [.createNote(noteToAdd,
                                       url: newModel.meta.noteMetaURL(for: noteToAdd),
                                       content: Note.Content(title: noteToAdd.title, cells: []),
                                       contentURL: newModel.meta.noteContentURL(for: noteToAdd))]
            case let .removeNote(noteToRemove):
                guard let indexOfRemovedNote = model.notes.index(of: noteToRemove) else { break }
                newModel = model |> Model.lens.notes .~ model.notes.removing(at: indexOfRemovedNote)
                effects = [.deleteNote(noteToRemove, url: newModel.meta.noteURL(for: noteToRemove))]
            case let .didReadDirectory(result):
                guard let urls = result.value else {
                    effects = [.handleError(title: Constants.notesLoadingErrorTitle,
                                            message: result.error!.localizedDescription)]
                    break
                }
                let notesURL = urls.filter(isNoteURL).map(toJSONmetaURL)
                effects = [.readNotes(urls: notesURL)]
            case let .didReadNotes(results):
                guard noErrorsInResults(results) else {
                    effects = [.handleError(title: Constants.notesLoadingErrorTitle,
                                            message: results |> reduceResultsToErrorSubString >>> String.init)]
                    break
                }
                newModel = model |> Model.lens.notes .~ results.map { $0.value! }
                effects = [.didLoadNotes(newModel.notes)]
            case let .didAddNote(note, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.notes .~ model.notes.removing(note)
                effects = [.removeDirectory(url: newModel.meta.noteURL(for: note))]
            case let .didDeleteNote(note, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.notes .~ model.notes.appending(note)
            case let .didUpdateNotebook(oldNotebook, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.meta.name .~ oldNotebook.name
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

internal extension Notebook.Meta {
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

private enum Constants {
    static let notesLoadingErrorTitle = "Failed to load notes"
}

private func isNoteURL(_ url: URL) -> Bool {
    return url.pathExtension == Notebook.Meta.Extension.note
}
