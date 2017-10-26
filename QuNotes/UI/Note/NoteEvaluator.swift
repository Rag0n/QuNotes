//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

extension UI.Note {
    struct Model {
        let note: Note
        let isNew: Bool
    }

    enum Action {
        case updateTitle(title: String)
        case updateContent(content: String)
        case addTag(tag: String)
        case removeTag(tag: String)
        case deleteNote
        case finish
    }

    enum ViewControllerEffect {
        case updateTitle(title: String)
        case focusOnTitle
        case updateContent(content: String)
        case showTags(tags: [String])
        case addTag(tag: String)
        case removeTag(tag: String)
        case showError(error: String, message: String)
    }

    enum CoordinatorEvent {
        case didUpdateTitle(result: Result<Note, AnyError>)
        case didUpdateContent(result: Result<Note, AnyError>)
        case didAddTag(result: Result<Note, AnyError>, tag: String)
        case didRemoveTag(result: Result<Note, AnyError>, tag: String)
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

        init(withNote note: Note, isNew: Bool) {
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
            case let .didUpdateTitle(result):
                guard case let .success(note) = result else {
                    let additionalEffect: ViewControllerEffect = .updateTitle(title: model.note.title)
                    return showError(error: result.error!,
                                     reason: "Failed to update note's title",
                                     model: model,
                                     additionalEffect: additionalEffect)
                }

                effects = [.updateTitle(title: note.title)]
                newModel = Model(note: note, isNew: model.isNew)
            case let .didUpdateContent(result):
                guard case let .success(note) = result else {
                    let additionalEffect: ViewControllerEffect = .updateContent(content: model.note.content)
                    return showError(error: result.error!,
                                     reason: "Failed to update note's content",
                                     model: model,
                                     additionalEffect: additionalEffect)
                }

                effects = [.updateContent(content: note.content)]
                newModel = Model(note: note, isNew: model.isNew)
            case let .didAddTag(result, tag):
                guard case let .success(note) = result else {
                    let additionalEffect: ViewControllerEffect = .showTags(tags: model.note.tags)
                    return showError(error: result.error!,
                                     reason: "Failed to add tag",
                                     model: model,
                                     additionalEffect: additionalEffect)
                }

                effects = [.addTag(tag: tag)]
                newModel = Model(note: note, isNew: model.isNew)
            case let .didRemoveTag(result, tag):
                guard case let .success(note) = result else {
                    let additionalEffect: ViewControllerEffect = .showTags(tags: model.note.tags)
                    return showError(error: result.error!,
                                     reason: "Failed to remove tag",
                                     model: model,
                                     additionalEffect: additionalEffect)
                }

                effects = [.removeTag(tag: tag)]
                newModel = Model(note: note, isNew: model.isNew)
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
        var effects: [ViewControllerEffect] = [
            .showError(error: reason, message: errorMessage)
        ]
        if let additionalEffect = additionalEffect {
            effects.insert(additionalEffect, at: 0)
        }

        return Evaluator(effects: effects,
                         actions: [],
                         model: model)
    }
}

// MARK: - ViewControllerEffect Equatable

extension UI.Note.ViewControllerEffect: Equatable {}

func ==(lhs: UI.Note.ViewControllerEffect, rhs: UI.Note.ViewControllerEffect) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lTitle), .updateTitle(let rTitle)):
        return lTitle == rTitle
    case (.focusOnTitle, .focusOnTitle):
        return true
    case (.updateContent(let lContent), .updateContent(let rContent)):
        return lContent == rContent
    case (.showTags(let lTags), .showTags(let rTags)):
        return lTags == rTags
    case (.addTag(let lTag), .addTag(let rTag)):
        return lTag == rTag
    case (.removeTag(let lTag), .removeTag(let rTag)):
        return lTag == rTag
    case (.showError(let lError, let lMessage), .showError(let rError, let rMessage)):
        return (lError == rError) && (lMessage == rMessage)
    default: return false
    }
}

// MARK: - Action Equtable

extension UI.Note.Action: Equatable {}

func ==(lhs: UI.Note.Action, rhs: UI.Note.Action) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lTitle), .updateTitle(let rTitle)):
        return lTitle == rTitle
    case (.updateContent(let lContent), .updateContent(let rContent)):
        return lContent == rContent
    case (.addTag(let lTag), .addTag(let rTag)):
        return lTag == rTag
    case (.removeTag(let lTag), .removeTag(let rTag)):
        return lTag == rTag
    case (.deleteNote, .deleteNote):
        return true
    case (.finish, .finish):
        return true
    default: return false
    }
}
