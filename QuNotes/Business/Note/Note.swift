//
//  Note.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

enum Note {
    struct Model: AutoEquatable {
        let meta: Meta
        let content: String
        let notebook: Notebook.Model?

        init(meta: Meta, content: String, notebook: Notebook.Model?) {
            self.meta = meta
            self.content = content
            self.notebook = notebook
        }
    }

    struct Meta: Codable, AutoEquatable {
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
                newModel = Model(uuid: model.uuid, title: newTitle, content: model.content,
                                 tags: model.tags, notebook: model.notebook,
                                 updatedDate: currentTimestamp(),
                                 createdDate: model.createdDate)
                guard let notebook = model.notebook else { break }
                let url = notebook.noteMetaURL(forNote: newModel)
                actions = [.updateFile(url: url, content: newModel.meta)]
            case let .changeContent(newContent):
                newModel = Model(uuid: model.uuid, title: model.title, content: newContent,
                                 tags: model.tags,
                                 notebook: model.notebook,
                                 updatedDate: currentTimestamp(),
                                 createdDate: model.createdDate)
                guard let notebook = model.notebook else { break }
                let fileContent = Content(content: newContent);
                let url = notebook.noteContentURL(forNote: newModel)
                actions = [.updateFile(url: url, content: fileContent)]
            case let .addTag(tag):
                guard !model.hasTag(tag) else { break }
                let newTags = model.tags + [tag]
                newModel = Model(uuid: model.uuid, title: model.title, content: model.content,
                                 tags: newTags,
                                 notebook: model.notebook,
                                 updatedDate: currentTimestamp(),
                                 createdDate: model.createdDate)
                guard let notebook = model.notebook else { break }
                let url = notebook.noteMetaURL(forNote: newModel)
                actions = [.updateFile(url: url, content: newModel.meta)]
            case let .removeTag(tag):
                guard let indexOfTag = model.tags.index(of: tag) else { break }
                let newTags = model.tags.removing(at: indexOfTag)
                newModel = Model(uuid: model.uuid, title: model.title, content: model.content,
                                 tags: newTags,
                                 notebook: model.notebook,
                                 updatedDate: currentTimestamp(),
                                 createdDate: model.createdDate)
                guard let notebook = model.notebook else { break }
                let url = notebook.noteMetaURL(forNote: newModel)
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

// MARK: Model API

extension Note.Model {
    var uuid: String {
        return meta.uuid
    }
    var title: String {
        return meta.title
    }
    var tags: [String] {
        return meta.tags
    }
    var createdDate: TimeInterval {
        return meta.created_at
    }
    var updatedDate: TimeInterval {
        return meta.updated_at
    }

    init(uuid: String,
         title: String,
         content: String,
         tags: [String],
         notebook: Notebook.Model?,
         updatedDate: TimeInterval,
         createdDate: TimeInterval) {
        let meta = Note.Meta(uuid: uuid, title: title, tags: tags, updated_at: updatedDate, created_at: createdDate)
        self.init(meta: meta, content: content, notebook: notebook)
    }
}

// MARK: - Private

private extension Note.Model {
    func hasTag(_ tag: String) -> Bool {
        return tags.index(of: tag) != nil
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
