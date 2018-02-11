//
//  Note.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Prelude
import Result

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
        case markdown
    }

    public enum Effect: AutoEquatable {
        case updateTitle(note: Meta, url: DynamicBaseURL, oldTitle: String)
        case updateContent(content: Content, url: DynamicBaseURL, oldContent: Content)
        case addTag(String, note: Meta, url: DynamicBaseURL)
        case removeTag(String, note: Meta, url: DynamicBaseURL)
        case readContent(url: DynamicBaseURL)
        case didLoadContent(Content)
        case handleError(title: String, message: String)
    }

    public enum Event {
        case loadContent
        case didReadContent(Result<Content, AnyError>)
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

        public func evaluating(event: Event) -> Evaluator {
            var effects: [Effect] = []
            var newModel = model

            switch event {
            case .loadContent:
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                effects = [.readContent(url: model.contentURL)]
            case let .didReadContent(result):
                guard case let .success(content) = result else {
                    effects = [.handleError(title: Constants.contentLoadingErrorTitle,
                                            message: result.error!.localizedDescription)]
                    break
                }
                newModel = model |> Model.lens.content .~ content
                effects = [.didLoadContent(content)]
            case let .changeTitle(newTitle):
                newModel = model |> Model.lens.meta.title .~ newTitle
                            |> Model.lens.content.title .~ newTitle
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                effects = [
                    .updateTitle(note: newModel.meta, url: newModel.metaURL, oldTitle: model.meta.title),
                    .updateContent(content: newModel.content, url: newModel.contentURL, oldContent: model.content)
                ]
            case let .changeCells(newCells):
                let newContent = Content(title: model.meta.title, cells: newCells)
                newModel = model |> Model.lens.content .~ newContent
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                effects = [.updateContent(content: newContent,
                                          url: model.contentURL,
                                          oldContent: model.content)]
            case let .addTag(tag):
                guard !model.hasTag(tag) else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.appending(tag)
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                effects = [.addTag(tag, note: newModel.meta, url: newModel.metaURL)]
            case let .removeTag(tag):
                guard let indexOfTag = model.meta.tags.index(of: tag) else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.removing(at: indexOfTag)
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                effects = [.removeTag(tag, note: newModel.meta, url: newModel.metaURL)]
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
    var metaURL: DynamicBaseURL {
        return notebook.noteMetaURL(for: meta)
    }

    var contentURL: DynamicBaseURL {
        return notebook.noteContentURL(for: meta)
    }

    func hasTag(_ tag: String) -> Bool {
        return meta.tags.index(of: tag) != nil
    }
}

private enum Constants {
    static let contentLoadingErrorTitle = "Failed to load content"
}
