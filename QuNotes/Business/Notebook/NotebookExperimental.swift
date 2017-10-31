//
//  NotebookExperimental.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

extension Experimental {
    enum Notebook {}
}

extension Experimental.Notebook {
    struct Model: Codable {
        let uuid: String
        let name: String
        let notes: [Experimental.Note.Model]
    }

    enum Action {
        case updateModel(model: Model)
        case createFile(url: URL)
    }

    enum InputEvent {
        case changeName(newName: String)
        case addNote(note: Experimental.Note.Model)
    }

    enum ResultEvent {
        case didChangeName(newName: String)
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
            case let .changeName(newName):
                let updatedModel = Model(uuid: model.uuid, name: newName, notes: model.notes)
                actions = [.updateModel(model: updatedModel)]
            case let .addNote(noteToAdd):
                let notes = model.notes + [noteToAdd]
                newModel = Model(uuid: model.uuid, name: model.name, notes: notes)
                let noteURL = URL(string: model.uuid)!
                    .appendingPathExtension("qvnotebook")
                    .appendingPathComponent(noteToAdd.uuid)
                    .appendingPathExtension("qvnote")
                actions = [.createFile(url: noteURL)]
            }

            return Evaluator(actions: actions, model: newModel)
        }

        func evaluate(event: ResultEvent) -> Evaluator {
            var actions: [Action] = []
            var newModel = model

            switch event {
            case let .didChangeName(newName):
                return Evaluator(actions: actions, model: newModel)
            }

            return Evaluator(actions: actions, model: newModel)
        }

        fileprivate init(actions: [Action], model: Model) {
            self.actions = actions
            self.model = model
        }
    }
}

extension Experimental.Notebook.Model: Equatable {
    static func ==(lhs: Experimental.Notebook.Model, rhs: Experimental.Notebook.Model) -> Bool {
        return (
            lhs.uuid == rhs.uuid &&
            lhs.name == rhs.name &&
            lhs.notes == rhs.notes
        )
    }
}

// MARK: - Action Equtable
extension Experimental.Notebook.Action: Equatable {}

func ==(lhs: Experimental.Notebook.Action, rhs: Experimental.Notebook.Action) -> Bool {
    switch (lhs, rhs) {
    case (.updateModel(let lModel), .updateModel(let rModel)):
        return lModel == rModel
    case (.createFile(let lURL), .createFile(let rURL)):
        return lURL == rURL
    default: return false
    }
}
