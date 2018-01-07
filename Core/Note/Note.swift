//
//  Note.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Prelude

public enum Note {
    public struct Model: AutoEquatable, AutoLens {
        public let meta: Meta
        public let content: Content
        public let notebook: Notebook.Meta

        public init(meta: Meta, content: Content, notebook: Notebook.Meta = Notebook.Meta.Unspecified) {
            self.meta = meta
            self.content = content
            self.notebook = notebook
        }
    }

    public struct Meta: Codable, AutoEquatable, AutoLens {
        public let uuid: String
        public let title: String
        public let tags: [String]
        public let updated_at: TimeInterval
        public let created_at: TimeInterval

        public init(uuid: String, title: String, tags: [String], updated_at: TimeInterval, created_at: TimeInterval) {
            self.uuid = uuid
            self.title = title
            self.tags = tags
            self.updated_at = updated_at
            self.created_at = created_at
        }
    }

    public struct Content: Codable, AutoEquatable, AutoLens {
        public let title: String
        public let cells: [Note.Cell]

        public init(title: String, cells: [Note.Cell]) {
            self.title = title
            self.cells = cells
        }
    }

    public struct Cell: Codable, AutoEquatable, AutoLens {
        public let type: CellType
        public let data: String

        public init(type: CellType, data: String) {
            self.type = type
            self.data = data
        }
    }

    public enum CellType: String, Codable {
        case text
    }

    public enum Effect: AutoEquatable {
        case updateTitle(note: Meta, url: URL, oldTitle: String)
        case updateContent(content: Content, url: URL, oldContent: Content)
        case addTag(String, note: Meta, url: URL)
        case removeTag(String, note: Meta, url: URL)
    }

    public enum Event {
        case changeTitle(String)
        case changeCells([Cell])
        case addTag(String)
        case removeTag(String)
        case didChangeTitle(oldTitle: String, error: Error?)
        case didChangeContent(oldContent: Content, error: Error?)
        case didAddTag(String, error: Error?)
        case didRemoveTag(String, error: Error?)
    }

    public struct Evaluator {
        public let effects: [Effect]
        public let model: Model
        var currentTimestamp: () -> Double = { Date().timeIntervalSince1970 }

        public init(model: Model) {
            self.model = model
            effects = []
        }

        public func evaluate(event: Event) -> Evaluator {
            var effects: [Effect] = []
            var newModel = model

            switch event {
            case let .changeTitle(newTitle):
                newModel = model |> Model.lens.meta.title .~ newTitle
                            |> Model.lens.content.title .~ newTitle
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let metaURL = model.notebook.noteMetaURL(for: newModel.meta)
                let contentURL = model.notebook.noteContentURL(for: newModel.meta)
                effects = [
                    .updateTitle(note: newModel.meta, url: metaURL, oldTitle: model.meta.title),
                    .updateContent(content: newModel.content, url: contentURL, oldContent: model.content)
                ]
            case let .changeCells(newCells):
                let newContent = Content(title: model.meta.title, cells: newCells)
                newModel = model |> Model.lens.content .~ newContent
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteContentURL(for: newModel.meta)
                effects = [.updateContent(content: newContent, url: url, oldContent: model.content)]
            case let .addTag(tag):
                guard !model.hasTag(tag) else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.appending(tag)
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteMetaURL(for: newModel.meta)
                effects = [.addTag(tag, note: newModel.meta, url: url)]
            case let .removeTag(tag):
                guard let indexOfTag = model.meta.tags.index(of: tag) else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.removing(at: indexOfTag)
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteMetaURL(for: newModel.meta)
                effects = [.removeTag(tag, note: newModel.meta, url: url)]
            case let .didChangeTitle(oldTitle, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.meta.title .~ oldTitle
                            |> Model.lens.content.title .~ oldTitle
            case let .didChangeContent(oldContent, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.content .~ oldContent
            case let .didAddTag(tag, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.removing(tag)
            case let .didRemoveTag(tag, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.appending(tag)
            }

            return Evaluator(effects: effects, model: newModel)
        }

        fileprivate init(effects: [Effect], model: Model) {
            self.effects = effects
            self.model = model
        }
    }
}

// MARK: - Private

private extension Note.Model {
    func hasTag(_ tag: String) -> Bool {
        return meta.tags.index(of: tag) != nil
    }
}
