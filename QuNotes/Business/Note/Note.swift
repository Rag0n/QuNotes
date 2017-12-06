//
//  Note.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

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

    struct Content: Codable, AutoEquatable {
        let content: String
    }

    enum Action {
        case updateFile(url: URL, content: Codable)
    }

    enum InputEvent {
        case changeTitle(newTitle: String)
        case changeContent(newContent: String)
        case addTag(tag: String)
        case removeTag(tag: String)
    }

    struct Evaluator {
        let actions: [Action]
        let model: Model
        var currentTimestamp: () -> Double = { Date().timeIntervalSince1970 }

        init(model: Model) {
            self.model = model
            actions = []
        }

        func evaluate(event: InputEvent) -> Evaluator {
            var actions: [Action] = []
            var newModel = model

            switch event {
            case let .changeTitle(newTitle):
                newModel = model |> Model.lens.meta.title .~ newTitle
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteMetaURL(for: newModel.meta)
                actions = [.updateFile(url: url, content: newModel.meta)]
            case let .changeContent(newContent):
                newModel = model |> Model.lens.content .~ newContent
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let fileContent = Content(content: newContent);
                let url = model.notebook.noteContentURL(for: newModel.meta)
                actions = [.updateFile(url: url, content: fileContent)]
            case let .addTag(tag):
                guard !model.hasTag(tag) else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.appending(tag)
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteMetaURL(for: newModel.meta)
                actions = [.updateFile(url: url, content: newModel.meta)]
            case let .removeTag(tag):
                guard let indexOfTag = model.meta.tags.index(of: tag) else { break }
                newModel = model |> Model.lens.meta.tags .~ model.meta.tags.removing(at: indexOfTag)
                            |> Model.lens.meta.updated_at .~ currentTimestamp()
                guard model.notebook != Notebook.Meta.Unspecified else { break }
                let url = model.notebook.noteMetaURL(for: newModel.meta)
                actions = [.updateFile(url: url, content: newModel.meta)]
            }

            return Evaluator(actions: actions, model: newModel)
        }

        fileprivate init(actions: [Action], model: Model) {
            self.actions = actions
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

// MARK: - Action Equtable
// TODO: Fix action type(similar to library) and replace this extension by autoequatable
extension Note.Action: Equatable {
    static func ==(lhs: Note.Action, rhs: Note.Action) -> Bool {
        switch (lhs, rhs) {
        case (.updateFile(let lURL, let lContent as Note.Meta),
              .updateFile(let rURL, let rContent as Note.Meta)):
            return (lURL == rURL) && (lContent == rContent)
        case (.updateFile(let lURL, let lContent as Note.Content),
              .updateFile(let rURL, let rContent as Note.Content)):
            return (lURL == rURL) && (lContent == rContent)
        default: return false
        }
    }
}
