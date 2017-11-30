//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

extension UI {
    enum Note {}
}

extension UI.Note {
    struct Model {
        let note: Note.Model
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

    enum ViewControllerEffect: AutoEquatable {
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

    enum ViewControllerEvent {
        case didLoad
        case changeContent(newContent: String)
        case changeTitle(newTitle: String)
        case delete
        case addTag(tag: String)
        case removeTag(tag: String)
    }

    // MARK: - Evaluator

    struct Evaluator {
        let effects: [ViewControllerEffect]
        let actions: [Action]
        let model: Model

        init(withNote note: Note.Model, isNew: Bool) {
            effects = []
            actions = []
            model = Model(note: note, isNew: isNew)
        }

        fileprivate init(effects: [ViewControllerEffect], actions: [Action], model: Model) {
            self.effects = effects
            self.actions = actions
            self.model = model
        }

        func evaluate(event: ViewControllerEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewControllerEffect] = []

            switch event {
            case .didLoad:
                effects = [
                    .updateTitle(title: model.note.title),
                    .updateContent(content: model.note.content),
                    .showTags(tags: model.note.tags)
                ]
                if model.isNew {
                    effects += [.focusOnTitle]
                }
            case let .changeContent(newContent):
                actions = [.updateContent(content: newContent)]
            case let .changeTitle(newTitle):
                actions = [.updateTitle(title: newTitle)]
            case .delete:
                actions = [.deleteNote]
            case let .addTag(tag):
                actions = [.addTag(tag: tag)]
            case let .removeTag(tag):
                actions = [.removeTag(tag: tag)]
            }

            return Evaluator(effects: effects, actions: actions, model: model)
        }

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewControllerEffect] = []
            var newModel = model

            switch event {
            case let .didDeleteNote(error):
                guard error == nil else {
                    return showError(error: error!,
                                     reason:  "Failed to delete note",
                                     model: model)
                }

                actions = [.finish]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}

// MARK: - Private

private extension UI.Note {
    static func showError(error: AnyError,
                          reason: String,
                          model: Model,
                          additionalEffect: ViewControllerEffect? = nil) -> Evaluator {
        let errorMessage = error.error.localizedDescription
        let actions: [Action] = [.showError(title: reason, message: errorMessage)]
        var effects: [ViewControllerEffect] = []
        if let additionalEffect = additionalEffect {
            effects.append(additionalEffect)
        }

        return Evaluator(effects: effects,
                         actions: actions,
                         model: model)
    }
}
