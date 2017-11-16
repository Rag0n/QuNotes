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
        case createNotebook(notebook: Experimental.Notebook.Model, url: URL)
        case deleteNotebook(notebook: Experimental.Notebook.Model, url: URL)
        case readFiles(url: URL, extension: String)
    }

    enum InputEvent {
        case loadNotebooks
        case addNotebook(notebook: Experimental.Notebook.Model)
        case removeNotebook(notebook: Experimental.Notebook.Meta)
        case didAddNotebook(notebook: Experimental.Notebook.Model, error: Error?)
        case didRemoveNotebook(notebook: Experimental.Notebook.Model, error: Error?)
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
            case .loadNotebooks:
                actions = [.readFiles(url: URL(string: "/")!, extension: "qvnotebook")]
            case let .addNotebook(notebook):
                guard !model.hasNotebook(withUUID: notebook.uuid) else { break }
                newModel = Model(notebooks: model.notebooks + [notebook])
                actions = [.createNotebook(notebook: notebook, url: notebook.noteBookMetaURL())]
            case let .removeNotebook(notebookMeta):
                guard let notebookToRemove = model.notebooks.filter({$0.uuid == notebookMeta.uuid}).first else {
                    break
                }
                let newNotebooks = model.notebooks.removeWithoutMutation(object: notebookToRemove)
                newModel = Model(notebooks: newNotebooks)
                actions = [.deleteNotebook(notebook: notebookToRemove, url: notebookToRemove.notebookURL())]
            case let .didAddNotebook(notebook, error):
                guard error != nil else { break }
                let updatedNotebooks = model.notebooks.removeWithoutMutation(object: notebook)
                newModel = Model(notebooks: updatedNotebooks)
            case let .didRemoveNotebook(notebook, error):
                guard error != nil else { break }
                let updatedNotebooks = model.notebooks + [notebook]
                newModel = Model(notebooks: updatedNotebooks)
            }

            return Evaluator(actions: actions, model: newModel)
        }

        private init(actions: [Action], model: Model) {
            self.model = model
            self.actions = actions
        }
    }
}

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
        case let (.createNotebook(lNotebook, lURL),
                  .createNotebook(rNotebook, rURL)):
            return (lURL == rURL) && (lNotebook == rNotebook)
        case let (.deleteNotebook(lNotebook, lURL),
                  .deleteNotebook(rNotebook, rURL)):
            return (lURL == rURL) && (lNotebook == rNotebook)
        case (.readFiles(let lURL, let lExtension),
              .readFiles(let rURL, let rExtension)):
            return (lURL == rURL) && (lExtension == rExtension)
        default: return false
        }
    }
}
