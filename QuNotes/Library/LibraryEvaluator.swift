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

enum Library {}

extension Library {
    // MARK: - Data types

    struct Model: AutoEquatable, AutoLens {
        let notebooks: [Core.Notebook.Meta]
    }
    
    enum Action: AutoEquatable {
        case addNotebook(notebook: Core.Notebook.Model)
        case deleteNotebook(notebook: Core.Notebook.Meta)
        case updateNotebook(notebook: Core.Notebook.Meta)
        case showNotebook(notebook: Core.Notebook.Meta)
        case reloadNotebook(notebook: Core.Notebook.Meta)
        case showError(title: String, message: String)
    }

    enum ViewEffect: AutoEquatable {
        case updateAllNotebooks(notebooks: [NotebookViewModel])
        case addNotebook(index: Int, notebooks: [NotebookViewModel])
        case updateNotebook(index: Int, notebooks:  [NotebookViewModel])
        case deleteNotebook(index: Int, notebooks: [NotebookViewModel])
    }

    enum CoordinatorEvent {
        case didLoadNotebooks(notebooks: [Core.Notebook.Meta])
        case didAddNotebook(notebook: Core.Notebook.Meta, error: Error?)
        case didDeleteNotebook(notebook: Core.Notebook.Meta, error: Error?)
        case didFinishShowing(notebook: Core.Notebook.Meta)
    }

    enum ViewEvent {
        case addNotebook
        case selectNotebook(index: Int)
        case deleteNotebook(index: Int)
        case updateNotebook(index: Int, title: String)
    }

    struct NotebookViewModel: AutoEquatable {
        let title: String
        let isEditable: Bool
    }

    // MARK: - Evaluator

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
                let notebook = Core.Notebook.Model(meta: Core.Notebook.Meta(uuid: generateUUID(), name: ""), notes: [])
                newModel = model |> Model.lens.notebooks
                    .~ model.notebooks.appending(notebook.meta).sorted(by: name)
                let indexOfNewNotebook = newModel.notebooks.index(of: notebook.meta)!
                effects = [.addNotebook(index: indexOfNewNotebook, notebooks: viewModels(from: newModel))]
                actions = [.addNotebook(notebook: notebook)]
            case let .deleteNotebook(index):
                guard index < model.notebooks.count else { break }
                let notebook = model.notebooks[index]
                newModel = model |> Model.lens.notebooks .~ model.notebooks.removing(at: index)
                effects = [.deleteNotebook(index: 0, notebooks: viewModels(from: newModel))]
                actions = [.deleteNotebook(notebook: notebook)]
            case let .selectNotebook(index):
                actions = [.showNotebook(notebook: model.notebooks[index])]
            case let .updateNotebook(index, title):
                guard index < model.notebooks.count else { break }
                let oldNotebook = model.notebooks[index]
                let updatedNotebook = Core.Notebook.Meta(uuid: oldNotebook.uuid, name: title)
                newModel = model |> Model.lens.notebooks
                    .~ model.notebooks.replacing(at: index, new: updatedNotebook).sorted(by: name)
                effects = [.updateNotebook(index: index, notebooks: viewModels(from: newModel))]
                actions = [.updateNotebook(notebook: updatedNotebook)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewEffect] = []
            var newModel = model

            switch event {
            case let .didLoadNotebooks(notebooks):
                newModel = model |> Model.lens.notebooks .~ notebooks.sorted(by: name)
                effects = [.updateAllNotebooks(notebooks: viewModels(from: newModel))]
            case let .didAddNotebook(notebook, error):
                guard let error = error else { break }
                // TODO: check if that notebook is still exist in model
                // If not - should do nothing
                // Also check if we are not select that notebook; If that notebook is selected,
                // then we need somehow to go back
                newModel = model |> Model.lens.notebooks .~ model.notebooks.removing(notebook)
                effects = [.updateAllNotebooks(notebooks: viewModels(from: newModel))]
                actions = [.showError(title: "Failed to add notebook", message: error.localizedDescription)]
            case let .didDeleteNotebook(notebook, error):
                guard let error = error else { break }
                newModel = model |> Model.lens.notebooks
                    .~ model.notebooks.appending(notebook).sorted(by: name)
                effects = [.updateAllNotebooks(notebooks: viewModels(from: newModel))]
                actions = [.showError(title: "Failed to delete notebook", message: error.localizedDescription)]
            case let .didFinishShowing(notebook):
                actions = [.reloadNotebook(notebook: notebook)]
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
