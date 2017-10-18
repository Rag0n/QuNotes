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
    struct EvaluatorResult {
        let updates: [ViewControllerUpdate]
        let actions: [Action]
        let model: Model
    }

    enum Action {
        case addNotebook
        case deleteNotebook(notebook: Notebook)
        case updateNotebook(notebook: Notebook, title: String)
        case showNotes(forNotebook: Notebook)
    }

    enum CoordinatorEvent {
        case didUpdateNotebooks(notebooks: [Notebook])
        case didAddNotebook(notebook: Notebook)
        case didDelete(notebook: Notebook)
        case didUpdate(notebook: Notebook)
        case failedToAddNotebook(error: AnyError)
        case failedToDeleteNotebook(error: AnyError)
        case failedToUpdateNotebook(error: AnyError)
    }

    struct Model {
        let notebooks: [Notebook]
        let editingNotebook: Notebook?
    }

    enum ViewControllerEvent {
        case addNotebook
        case selectNotebook(index: Int)
        case deleteNotebook(index: Int)
        case updateNotebook(index: Int, title: String)
    }

    enum ViewControllerUpdate {
        case updateAllNotebooks(notebooks: [NotebookCellViewModel])
        case addNotebook(index: Int, notebooks: [NotebookCellViewModel])
        case updateNotebook(index: Int, notebooks:  [NotebookCellViewModel])
        case deleteNotebook(index: Int, notebooks: [NotebookCellViewModel])
        case showError(error: String, message: String)
    }

    static func initialModel() -> Model {
        return Model(notebooks: [], editingNotebook: nil)
    }

    static func evaluateController(event: ViewControllerEvent, model: Model) -> EvaluatorResult {
        var actions: [Action] = []
        let updates: [ViewControllerUpdate] = []

        switch event {
        case .addNotebook:
            actions = [.addNotebook]
        case .deleteNotebook(let index):
            let notebook = model.notebooks[index]
            actions = [.deleteNotebook(notebook: notebook)]
        case .selectNotebook(let index):
            let notebook = model.notebooks[index]
            actions = [.showNotes(forNotebook: notebook)]
        case .updateNotebook(let index, let title):
            let notebook = model.notebooks[index]
            actions = [.updateNotebook(notebook: notebook, title: title)]
        }

        return EvaluatorResult(updates: updates, actions: actions, model: model)
    }

    static func evaluateCoordinator(event: CoordinatorEvent, model: Model) -> EvaluatorResult {
        let actions: [Action] = []
        var updates: [ViewControllerUpdate] = []
        var newModel = model

        switch event {
        case .didUpdateNotebooks(let notebooks):
            let sortedNotebooks = notebooks.sorted(by: defaultNotebookSorting)
            let notebookViewModels = viewModels(fromNotebooks: sortedNotebooks, editingNotebook: model.editingNotebook)
            updates = [.updateAllNotebooks(notebooks: notebookViewModels)]
            newModel = Model(notebooks: sortedNotebooks, editingNotebook: nil)
        case .didAddNotebook(let notebook):
            let updatedNotebooks = model.notebooks + [notebook]
            let sortedNotebooks = updatedNotebooks.sorted(by: defaultNotebookSorting)
            let notebookViewModels = viewModels(fromNotebooks: sortedNotebooks, editingNotebook: notebook)
            let indexOfNewNotebook = sortedNotebooks.index(of: notebook)!
            updates = [.addNotebook(index: indexOfNewNotebook, notebooks: notebookViewModels)]
            newModel = Model(notebooks: sortedNotebooks, editingNotebook: notebook)
        case .didDelete(let notebook):
            let indexOfDeletedNotebook = model.notebooks.index(of: notebook)!
            let updatedNotebooks = model.notebooks.removeWithoutMutation(at: indexOfDeletedNotebook)
            let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
            updates = [.deleteNotebook(index: indexOfDeletedNotebook, notebooks: notebookViewModels)]
            newModel = Model(notebooks: updatedNotebooks, editingNotebook: model.editingNotebook)
        case .didUpdate(let notebook):
            let indexOfUpdatedNotebook = model.notebooks.index(of: notebook)!
            var updatedNotebooks = model.notebooks
            updatedNotebooks[indexOfUpdatedNotebook] = notebook
            updatedNotebooks = updatedNotebooks.sorted(by: defaultNotebookSorting)
            let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
            updates = [.updateAllNotebooks(notebooks: notebookViewModels)]
            newModel = Model(notebooks: updatedNotebooks, editingNotebook: nil)
        case .failedToAddNotebook(let error):
            let errorMessage = error.error.localizedDescription
            let notebookViewModels = viewModels(fromNotebooks: model.notebooks)
            updates = [
                .updateAllNotebooks(notebooks: notebookViewModels),
                .showError(error: "Failed to add notebook", message: errorMessage)
            ]
            newModel = Model(notebooks: model.notebooks, editingNotebook: nil)
        case .failedToDeleteNotebook(let error):
            let errorMessage = error.error.localizedDescription
            let notebookViewModels = viewModels(fromNotebooks: model.notebooks, editingNotebook: model.editingNotebook)
            updates = [
                .updateAllNotebooks(notebooks: notebookViewModels),
                .showError(error: "Failed to delete notebook", message: errorMessage)
            ]
        case .failedToUpdateNotebook(let error):
            let errorMessage = error.error.localizedDescription
            let notebookViewModels = viewModels(fromNotebooks: model.notebooks, editingNotebook: model.editingNotebook)
            updates = [
                .updateAllNotebooks(notebooks: notebookViewModels),
                .showError(error: "Failed to update notebook", message: errorMessage)
            ]
        }

        return EvaluatorResult(updates: updates, actions: actions, model: newModel)
    }
}

private extension UI.Library {
    static func viewModels(fromNotebooks: [Notebook], editingNotebook: Notebook? = nil) -> [NotebookCellViewModel] {
        return fromNotebooks.map {
            NotebookCellViewModel(title: $0.name, isEditable: $0 == editingNotebook)
        }
    }

    static func defaultNotebookSorting(leftNotebook: Notebook, rightNotebook: Notebook) -> Bool {
        return leftNotebook.name < rightNotebook.name
    }
}
