//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

extension UI.Note {
    struct Model {
        let note: Note
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
        case updateContent(content: String)
        case showTags(tags: [String])
        case addTag(tag: String)
        case removeTag(tag: String)
        case showError(error: String, message: String)
    }

    enum CoordinatorEvent {
        case didUpdateTitle(note: Note)
        case didUpdateContent(note: Note)
        case didAddTag(note: Note, tag: String)
        case didRemoveTag(note: Note, tag: String)
        case didDeleteNote
        case didFailToUpdateTitle(error: AnyError)
        case didFailToUpdateContent(error: AnyError)
        case didFailToAddTag(error: AnyError)
        case didFailToRemoveTag(error: AnyError)
        case didFailToDeleteNote(error: AnyError)
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

        init(withNote note: Note) {
            effects = []
            actions = []
            model = Model(note: note)
        }

        private init(effects: [ViewControllerEffect], actions: [Action], model: Model) {
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
            case let .didUpdateTitle(note):
                effects = [.updateTitle(title: note.title)]
                newModel = Model(note: note)
            case let .didUpdateContent(note):
                effects = [.updateContent(content: note.content)]
                newModel = Model(note: note)
            case let .didAddTag(note, tag):
                effects = [.addTag(tag: tag)]
                newModel = Model(note: note)
            case let .didRemoveTag(note, tag):
                effects = [.removeTag(tag: tag)]
                newModel = Model(note: note)
            case .didDeleteNote:
                actions = [.finish]
            case let .didFailToUpdateTitle(error):
                let errorMessage = error.error.localizedDescription
                effects = [
                    .updateTitle(title: model.note.title),
                    .showError(error: "Failed to update note's title", message: errorMessage)
                ]
            case let .didFailToUpdateContent(error):
                let errorMessage = error.error.localizedDescription
                effects = [
                    .updateContent(content: model.note.content),
                    .showError(error: "Failed to update note's content", message: errorMessage)
                ]
            case let .didFailToAddTag(error):
                let errorMessage = error.error.localizedDescription
                effects = [
                    .showTags(tags: model.note.tags),
                    .showError(error: "Failed to add tag", message: errorMessage)
                ]
            case let .didFailToRemoveTag(error):
                let errorMessage = error.error.localizedDescription
                effects = [
                    .showTags(tags: model.note.tags),
                    .showError(error: "Failed to remove tag", message: errorMessage)
                ]
            case let .didFailToDeleteNote(error):
                let errorMessage = error.error.localizedDescription
                effects = [.showError(error: "Failed to delete note", message: errorMessage)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}

// MARK: - ViewControllerEffect Equatable

extension UI.Note.ViewControllerEffect: Equatable {}

func ==(lhs: UI.Note.ViewControllerEffect, rhs: UI.Note.ViewControllerEffect) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lTitle), .updateTitle(let rTitle)):
        return lTitle == rTitle
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
