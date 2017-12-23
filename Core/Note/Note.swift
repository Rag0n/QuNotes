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
        public let content: String
        public let notebook: Notebook.Meta

        public init(meta: Meta, content: String, notebook: Notebook.Meta = Notebook.Meta.Unspecified) {
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

    public enum Effect: AutoEquatable {
        case updateTitle(note: Meta, url: URL, oldTitle: String)
        case updateContent(content: String, url: URL, oldContent: String)
        case addTag(note: Meta, url: URL, tag: String)
        case removeTag(note: Meta, url: URL, tag: String)
    }

    public enum Event {
        case changeTitle(newTitle: String)
        case changeContent(newContent: String)
        case addTag(tag: String)
        case removeTag(tag: String)
        case didChangeTitle(oldTitle: String, error: Error?)
        case didChangeContent(oldContent: String, error: Error?)
        case didAddTag(tag: String, error: Error?)
        case didRemoveTag(tag: String, error: Error?)
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
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteMetaURL(for: newModel.meta)
                effects = [.updateTitle(note: newModel.meta, url: url, oldTitle: model.meta.title)]
            case let .changeContent(newContent):
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
                effects = [.addTag(note: newModel.meta, url: url, tag: tag)]
            case let .removeTag(tag):
                guard let indexOfTag = model.meta.tags.index(of: tag) else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.removing(at: indexOfTag)
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteMetaURL(for: newModel.meta)
                effects = [.removeTag(note: newModel.meta, url: url, tag: tag)]
            case let .didChangeTitle(oldTitle, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.meta.title .~ oldTitle
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
