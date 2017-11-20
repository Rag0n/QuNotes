//
//  LibraryEvaluator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 08.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

extension UI.Library {
    // MARK: - Data types

    struct Model: AutoEquatable {
        let notebooks: [Experimental.Notebook.Meta]
    }
    
    enum Action: AutoEquatable {
        case addNotebook(notebook: Experimental.Notebook.Model)
        case deleteNotebook(notebook: Experimental.Notebook.Meta)
        case showNotes(forNotebook: UseCase.Notebook)
        case showError(title: String, message: String)
    }

    enum ViewControllerEffect: AutoEquatable {
        case updateAllNotebooks(notebooks: [NotebookViewModel])
        case addNotebook(index: Int, notebooks: [NotebookViewModel])
        case updateNotebook(index: Int, notebooks:  [NotebookViewModel])
        case deleteNotebook(index: Int, notebooks: [NotebookViewModel])
    }

    enum CoordinatorEvent {
        case didAddNotebook(notebook: Experimental.Notebook.Meta, error: Error?)
        case didDeleteNotebook(notebook: Experimental.Notebook.Meta, error: Error?)
    }

    enum ViewControllerEvent {
        case addNotebook
        case selectNotebook(index: Int)
        case deleteNotebook(index: Int)
        case updateNotebook(index: Int, title: String?)
    }

    struct NotebookViewModel: AutoEquatable {
        let title: String
        let isEditable: Bool
    }

    // MARK: - Evaluator

    struct Evaluator {
        let effects: [ViewControllerEffect]
        let actions: [Action]
        let model: Model
        var uuidGenerator: () -> String = { UUID().uuidString }

        init(notebooks: [Experimental.Notebook.Meta] = []) {
            effects = []
            actions = []
            model = Model(notebooks: notebooks)
        }

        func evaluate(event: ViewControllerEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewControllerEffect] = []
            var newModel = model

            switch event {
            case .addNotebook:
                let notebook = Experimental.Notebook.Model(uuid: uuidGenerator(), name: "", notes: [])
                let updatedNotebooks = model.notebooks + [notebook.meta]
                let sortedNotebooks = updatedNotebooks.sorted(by: notebookNameSorting)
                let indexOfNewNotebook = sortedNotebooks.index(of: notebook.meta)!
                let notebookViewModels = viewModels(fromNotebooks: sortedNotebooks)
                newModel = Model(notebooks: sortedNotebooks)
                effects = [.addNotebook(index: indexOfNewNotebook, notebooks: notebookViewModels)]
                actions = [.addNotebook(notebook: notebook)]
            case let .deleteNotebook(index):
                guard index < model.notebooks.count else { break }
                let notebook = model.notebooks[index]
                let updatedNotebooks = model.notebooks.removeWithoutMutation(at: index)
                let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
                effects = [.deleteNotebook(index: 0, notebooks: notebookViewModels)]
                newModel = Model(notebooks: updatedNotebooks)
                actions = [.deleteNotebook(notebook: notebook)]
            case let .selectNotebook(index):
                actions = []
            case let .updateNotebook(index, title):
                actions = []
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewControllerEffect] = []
            var newModel = model

            switch event {
            case let .didAddNotebook(notebook, error):
                guard let error = error else { break }
                // TODO: check if that notebook is still exist in model
                // If not - should do nothing
                // Also check if we are not select that notebook; If that notebook is selected,
                // then we need somehow to go back
                let updatedNotebooks = model.notebooks.removeWithoutMutation(object: notebook)
                newModel = Model(notebooks: updatedNotebooks)
                let updatedViewModels = viewModels(fromNotebooks: updatedNotebooks)
                effects = [.updateAllNotebooks(notebooks: updatedViewModels)]
                actions = [.showError(title: "Failed to add notebook", message: error.localizedDescription)]
            case let .didDeleteNotebook(notebook, error):
                guard let error = error else { break }
                let updatedNotebookMetas = model.notebooks + [notebook]
                let sortedNotebookMetas = updatedNotebookMetas.sorted(by: notebookNameSorting)
                let notebookViewModels = viewModels(fromNotebooks: sortedNotebookMetas)
                newModel = Model(notebooks: sortedNotebookMetas)
                effects = [.updateAllNotebooks(notebooks: notebookViewModels)]
                actions = [.showError(title: "Failed to delete notebook", message: error.localizedDescription)]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }

        fileprivate init(effects: [ViewControllerEffect], actions: [Action], model: Model) {
            self.effects = effects
            self.actions = actions
            self.model = model
        }
    }
}

// MARK: - Private

private extension UI.Library {
    static func viewModels(fromNotebooks: [Experimental.Notebook.Meta]) -> [NotebookViewModel] {
        return fromNotebooks.map {
            NotebookViewModel(title: $0.name, isEditable: false)
        }
    }

    static func notebookNameSorting(lhs: Experimental.Notebook.Meta, rhs: Experimental.Notebook.Meta) -> Bool {
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
}
