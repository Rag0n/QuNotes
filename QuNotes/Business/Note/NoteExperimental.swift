//
//  NoteExperimental.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

extension Experimental {
    enum Note {}
}

extension Experimental.Note {
    struct Model {
        let uuid: String
        let title: String
        let content: String
        let notebook: Experimental.Notebook.Model?

        init(uuid: String,
             title: String,
             content: String,
             notebook: Experimental.Notebook.Model? = nil) {
            self.uuid = uuid
            self.title = title
            self.content = content
            self.notebook = notebook
        }
    }

    struct Meta: Codable {
        let uuid: String
        let title: String
    }

    struct Content: Codable {
        let content: String
    }

    enum Action {
        case updateFile(url: URL, content: Codable)
    }

    enum InputEvent {
        case changeTitle(newTitle: String)
        case changeContent(newContent: String)
    }

    struct Evaluator {
        let actions: [Action]
        let model: Model

        init(model: Model) {
            self.model = model
            actions = []
        }

        func evaluate(event: InputEvent) -> Evaluator {
            var actions: [Action] = []
            var newModel = model

            switch event {
            case let .changeTitle(newTitle):
                newModel = Model(uuid: model.uuid, title: newTitle, content: model.content)
                if let notebook = model.notebook {
                    let fileContent = Meta(uuid: newModel.uuid, title: newModel.title)
                    let url = notebook.noteMetaURL(forNote: newModel)
                    actions = [.updateFile(url: url, content: fileContent)]
                }
            case let .changeContent(newContent):
                newModel = Model(uuid: model.uuid, title: model.title, content: newContent)
                if let notebook = model.notebook {
                    let fileContent = Content(content: newContent);
                    let url = notebook.noteContentURL(forNote: newModel)
                    actions = [.updateFile(url: url, content: fileContent)]
                }
            }

            return Evaluator(actions: actions, model: newModel)
        }

        fileprivate init(actions: [Action], model: Model) {
            self.actions = actions
            self.model = model
        }
    }
}

// MARK: Datatypes equatable

extension Experimental.Note.Model: Equatable {
    static func ==(lhs: Experimental.Note.Model, rhs: Experimental.Note.Model) -> Bool {
        return (
            lhs.uuid == rhs.uuid &&
            lhs.title == rhs.title &&
            lhs.content == rhs.content
        )
    }
}

extension Experimental.Note.Meta: Equatable {
    static func ==(lhs: Experimental.Note.Meta, rhs: Experimental.Note.Meta) -> Bool {
        return (
            lhs.uuid == rhs.uuid &&
            lhs.title == rhs.title
        )
    }
}

extension Experimental.Note.Content: Equatable {
    static func ==(lhs: Experimental.Note.Content, rhs: Experimental.Note.Content) -> Bool {
        return lhs.content == rhs.content
    }
}

// MARK: - Action Equtable

extension Experimental.Note.Action: Equatable {
    static func ==(lhs: Experimental.Note.Action, rhs: Experimental.Note.Action) -> Bool {
        switch (lhs, rhs) {
        case (.updateFile(let lURL, let lContent as Experimental.Note.Meta),
              .updateFile(let rURL, let rContent as Experimental.Note.Meta)):
            return (lURL == rURL) && (lContent == rContent)
        case (.updateFile(let lURL, let lContent as Experimental.Note.Content),
              .updateFile(let rURL, let rContent as Experimental.Note.Content)):
            return (lURL == rURL) && (lContent == rContent)
        default: return false
        }
    }
}
