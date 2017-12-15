//
//  Note.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Prelude

enum Note {
    struct Model: AutoEquatable, AutoLens {
        let meta: Meta
        let content: String
        let notebook: Notebook.Meta

        init(meta: Meta, content: String, notebook: Notebook.Meta = Notebook.Meta.Unspecified) {
            self.meta = meta
            self.content = content
            self.notebook = notebook
        }
    }

    struct Meta: Codable, AutoEquatable, AutoLens {
        let uuid: String
        let title: String
        let tags: [String]
        let updated_at: TimeInterval
        let created_at: TimeInterval
    }

    enum Effect: AutoEquatable {
        case updateTitle(note: Meta, url: URL)
        case updateContent(content: String, url: URL)
        case addTag(note: Meta, url: URL)
        case removeTag(note: Meta, url: URL)
    }

    enum Event {
        case changeTitle(newTitle: String)
        case changeContent(newContent: String)
        case addTag(tag: String)
        case removeTag(tag: String)
    }

    struct Evaluator {
        let effects: [Effect]
        let model: Model
        var currentTimestamp: () -> Double = { Date().timeIntervalSince1970 }

        init(model: Model) {
            self.model = model
            effects = []
        }

        func evaluate(event: Event) -> Evaluator {
            var effects: [Effect] = []
            var newModel = model

            switch event {
            case let .changeTitle(newTitle):
                newModel = model |> Model.lens.meta.title .~ newTitle
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteMetaURL(for: newModel.meta)
                effects = [.updateTitle(note: newModel.meta, url: url)]
            case let .changeContent(newContent):
                newModel = model |> Model.lens.content .~ newContent
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteContentURL(for: newModel.meta)
                effects = [.updateContent(content: newContent, url: url)]
            case let .addTag(tag):
                guard !model.hasTag(tag) else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.appending(tag)
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteMetaURL(for: newModel.meta)
                effects = [.addTag(note: newModel.meta, url: url)]
            case let .removeTag(tag):
                guard let indexOfTag = model.meta.tags.index(of: tag) else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.removing(at: indexOfTag)
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteMetaURL(for: newModel.meta)
                effects = [.removeTag(note: newModel.meta, url: url)]
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
