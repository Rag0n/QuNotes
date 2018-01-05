//
//  LibraryEvaluator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 08.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Prelude
import Core

extension Library {
    struct Evaluator {
        let effects: [ViewEffect]
        let actions: [Action]
        let model: Model
        var generateUUID: () -> String = { UUID().uuidString }

        init(notebooks: [Core.Notebook.Meta] = []) {
            effects = []
            actions = []
            model = Model(notebooks: notebooks)
        }

        func evaluate(event: ViewEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case .addNotebook:
                let notebook = Core.Notebook.Meta(uuid: generateUUID(), name: "")
                newModel = model |> Model.lens.notebooks
                    .~ model.notebooks.appending(notebook).sorted(by: name)
                let indexOfNewNotebook = newModel.notebooks.index(of: notebook)!
                effects = [.addNotebook(index: indexOfNewNotebook, notebooks: viewModels(from: newModel))]
                actions = [.addNotebook(notebook)]
            case let .deleteNotebook(index):
                guard index < model.notebooks.count else { break }
                let notebook = model.notebooks[index]
                newModel = model |> Model.lens.notebooks .~ model.notebooks.removing(at: index)
                effects = [.deleteNotebook(index: index, notebooks: viewModels(from: newModel))]
                actions = [.deleteNotebook(notebook)]
            case let .selectNotebook(index):
                actions = [.showNotebook(model.notebooks[index])]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case let .updateNotebook(notebook):
                guard let index = model.index(ofNotebook: notebook) else { break }
                newModel = model |> Model.lens.notebooks .~
                    model.notebooks.replacing(at: index, new: notebook).sorted(by: name)
                effects = [.updateAllNotebooks(viewModels(from: newModel))]
            case let .deleteNotebook(notebook):
                guard let index = model.index(ofNotebook: notebook) else { break }
                newModel = model |> Model.lens.notebooks .~
                    model.notebooks.removing(at: index)
                effects = [.deleteNotebook(index: index, notebooks: viewModels(from: newModel))]
                actions = [.deleteNotebook(notebook)]
            case let .didLoadNotebooks(notebooks):
                newModel = model |> Model.lens.notebooks .~ notebooks.sorted(by: name)
                effects = [.updateAllNotebooks(viewModels(from: newModel))]
            case let .didAddNotebook(notebook, error):
                guard let error = error else { break }
                // TODO: check if that notebook is still exist in model
                // If not - should do nothing
                // Also check if we are not select that notebook; If that notebook is selected,
                // then we need somehow to go back
                newModel = model |> Model.lens.notebooks .~ model.notebooks.removing(notebook)
                effects = [.updateAllNotebooks(viewModels(from: newModel))]
                actions = [.showError(title: "Failed to add notebook", message: error.localizedDescription)]
            case let .didDeleteNotebook(notebook, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.notebooks
                    .~ model.notebooks.appending(notebook).sorted(by: name)
                effects = [.updateAllNotebooks(viewModels(from: newModel))]
                actions = [.showError(title: "Failed to delete notebook", message: error.localizedDescription)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }

        fileprivate init(effects: [ViewEffect], actions: [Action], model: Model) {
            self.effects = effects
            self.actions = actions
            self.model = model
        }
    }
}

// MARK: - Private

private extension Library {
    static func viewModels(from model: Model) -> [NotebookViewModel] {
        return model.notebooks.map {
            NotebookViewModel(title: $0.name, isEditable: false)
        }
    }

    static func name(lhs: Core.Notebook.Meta, rhs: Core.Notebook.Meta) -> Bool {
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
}

private extension Library.Model {
    func index(ofNotebook notebook: Core.Notebook.Meta) -> Array<Core.Notebook.Meta>.Index? {
        return notebooks.index { $0.uuid == notebook.uuid }
    }
}
