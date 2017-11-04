//
//  LibraryExperimental.swift
//  QuNotes
//
//  Created by Alexander Guschin on 03.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

extension Experimental {
    enum Library {}
}

extension Experimental.Library {
    struct Model {
        let notebooks: [Experimental.Notebook.Model]
    }

    enum Action {
        case createFile(url: URL, content: Codable)
    }

    enum InputEvent {
        case addNotebook(notebook: Experimental.Notebook.Model)
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

            switch (event) {
            case let .addNotebook(notebook):
                guard !model.hasNotebook(withUUID: notebook.uuid) else { break }
                newModel = Model(notebooks: model.notebooks + [notebook])
                let fileURL = notebook.noteBookMetaURL()
                let fileContent = Experimental.Notebook.Meta(uuid: notebook.uuid, name: notebook.name)
                actions = [.createFile(url: fileURL, content: fileContent)]
            }

            return Evaluator(actions: actions, model: newModel)
        }

        private init(actions: [Action], model: Model) {
            self.model = model
            self.actions = actions
        }
    }
}

// MARK: - Model API

// MARL: - Private

private extension Experimental.Library.Model {
    func hasNotebook(withUUID notebookUUID: String) -> Bool {
        return notebooks.filter({ $0.uuid == notebookUUID }).count > 0
    }
}

// MARK: - Datatypes equtable

extension Experimental.Library.Model: Equatable {
    static func ==(lhs: Experimental.Library.Model, rhs: Experimental.Library.Model) -> Bool {
        return lhs.notebooks == rhs.notebooks
    }
}

extension Experimental.Library.Action: Equatable {
    static func ==(lhs: Experimental.Library.Action, rhs: Experimental.Library.Action) -> Bool {
        switch (lhs, rhs) {
        case (.createFile(let lURL, let lContent as Experimental.Notebook.Meta),
              .createFile(let rURL, let rContent as Experimental.Notebook.Meta)):
            return (lURL == rURL) && (lContent == rContent)
        default: return false
        }
    }
}

// MARK: - Action Equtable
