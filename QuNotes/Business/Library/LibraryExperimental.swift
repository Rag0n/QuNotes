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
        case createNotebook(notebook: Experimental.Notebook.Meta, url: URL)
        case deleteFile(url: URL)
        case readFiles(url: URL, extension: String)
    }

    enum InputEvent {
        case loadNotebooks
        case addNotebook(notebook: Experimental.Notebook.Model)
        case failedToAddNotebook(notebook: Experimental.Notebook.Meta)
        case removeNotebook(notebook: Experimental.Notebook.Model)
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
                let notebookMeta = Experimental.Notebook.Meta(uuid: notebook.uuid, name: notebook.name)
                actions = [.createNotebook(notebook: notebookMeta, url: notebook.noteBookMetaURL())]
            case let .failedToAddNotebook(notebook):
                guard let notebook = model.notebooks.filter({$0.uuid == notebook.uuid}).first else { break }
                let updatedNotebooks = model.notebooks.removeWithoutMutation(object: notebook)
                newModel = Model(notebooks: updatedNotebooks)
            case let .removeNotebook(notebook):
                guard let indexOfRemovedNotebook = model.notebooks.index(of: notebook) else { break }
                let newNotebooks = model.notebooks.removeWithoutMutation(at: indexOfRemovedNotebook)
                newModel = Model(notebooks: newNotebooks)
                let fileURL = notebook.notebookURL()
                actions = [.deleteFile(url: fileURL)]
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
        case let (.createNotebook(lNotebook, lURL),
                  .createNotebook(rNotebook, rURL)):
            return (lURL == rURL) && (lNotebook == rNotebook)
        case (.deleteFile(let lURL), .deleteFile(let rURL)):
            return lURL == rURL
        case (.readFiles(let lURL, let lExtension),
              .readFiles(let rURL, let rExtension)):
            return (lURL == rURL) && (lExtension == rExtension)
        default: return false
        }
    }
}

// MARK: - Action Equtable
