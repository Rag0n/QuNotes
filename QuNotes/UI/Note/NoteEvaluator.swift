//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result
import Prelude
import Core

extension UI {
    enum Note {}
}

extension UI.Note {
    struct Model: AutoEquatable, AutoLens {
        let meta: Note.Meta
        let content: String
        let isNew: Bool
    }

    enum Action: AutoEquatable {
        case updateTitle(title: String)
        case updateContent(content: String)
        case addTag(tag: String)
        case removeTag(tag: String)
        case deleteNote
        case finish
        case showError(title: String, message: String)
    }

    enum ViewEffect: AutoEquatable {
        case updateTitle(title: String)
        case focusOnTitle
        case updateContent(content: String)
        case showTags(tags: [String])
        case addTag(tag: String)
        case removeTag(tag: String)
    }

    enum CoordinatorEvent {
        case didDeleteNote(error: AnyError?)
    }

    enum ViewEvent {
        case didLoad
        case changeContent(newContent: String)
        case changeTitle(newTitle: String)
        case delete
        case addTag(tag: String)
        case removeTag(tag: String)
    }

    // MARK: - Evaluator

    struct Evaluator {
        let effects: [ViewEffect]
        let actions: [Action]
        let model: Model

        init(note: Note.Meta, content: String, isNew: Bool) {
            effects = []
            actions = []
            model = Model(meta: note, content: content, isNew: isNew)
        }

        fileprivate init(effects: [ViewEffect], actions: [Action], model: Model) {
            self.effects = effects
            self.actions = actions
            self.model = model
        }

        func evaluate(event: ViewEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case .didLoad:
                effects = [
                    .updateTitle(title: model.meta.title),
                    .showTags(tags: model.meta.tags)
                ]
                if model.isNew {
                    effects += [.focusOnTitle]
                }
            case let .changeContent(newContent):
                newModel = model |> Model.lens.content .~ newContent
                actions = [.updateContent(content: newContent)]
                effects = [.updateContent(content: newContent)]
            case let .changeTitle(newTitle):
                // TODO: Fix lens composition
                newModel = Model(meta: Note.Meta(uuid: model.meta.uuid, title: newTitle, tags: model.meta.tags, updated_at: model.meta.updated_at,
                                                 created_at: model.meta.created_at), content: model.content, isNew: model.isNew)
                actions = [.updateTitle(title: newTitle)]
                effects = [.updateTitle(title: newTitle)]
            case .delete:
                actions = [.deleteNote]
            case let .addTag(tag):
                // TODO: Fix lens composition
                newModel = Model(meta: Note.Meta(uuid: model.meta.uuid, title: model.meta.title, tags: model.meta.tags.appending(tag),
                                                 updated_at: model.meta.updated_at, created_at: model.meta.created_at),
                                 content: model.content, isNew: model.isNew)
                actions = [.addTag(tag: tag)]
                effects = [.addTag(tag: tag)]
            case let .removeTag(tag):
                // TODO: Fix lens composition
                newModel = Model(meta: Note.Meta(uuid: model.meta.uuid, title: model.meta.title, tags: model.meta.tags.removing(tag),
                                                 updated_at: model.meta.updated_at, created_at: model.meta.created_at),
                                 content: model.content, isNew: model.isNew)
                actions = [.removeTag(tag: tag)]
                effects = [.removeTag(tag: tag)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case let .didDeleteNote(error):
                if let error = error {
                    actions = [.showError(title: "Failed to delete note", message: error.localizedDescription)]
                } else {
                    actions = [.finish]
                }
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}
