//
//  LibraryEvaluator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 08.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

struct LibraryEvaluatorResult {
    let updates: [LibraryViewControllerUpdate]
    let actions: [LibraryCoordinatorAction]
    let model: LibraryCoordinatorModel
}

enum LibraryEvaluator {}

extension LibraryEvaluator {
    static func initialModel() -> LibraryCoordinatorModel {
        return LibraryCoordinatorModel(notebooks: [], editingNotebook: nil)
    }
}

extension LibraryEvaluator {
    static func evaluateController(event: LibraryViewControllerEvent, model: LibraryCoordinatorModel) -> LibraryEvaluatorResult {
        var actions: [LibraryCoordinatorAction] = []
        let updates: [LibraryViewControllerUpdate] = []

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

        return LibraryEvaluatorResult(updates: updates, actions: actions, model: model)
    }
}

extension LibraryEvaluator {
    static func evaluateUseCase(event: NotebookUseCaseEvent, model: LibraryCoordinatorModel) -> LibraryEvaluatorResult {
        let actions: [LibraryCoordinatorAction] = []
        var updates: [LibraryViewControllerUpdate] = []
        var newModel = model

        switch event {
        case .didUpdateNotebooks(let notebooks):
            let sortedNotebooks = notebooks.sorted(by: defaultNotebookSorting)
            let notebookViewModels = viewModels(fromNotebooks: sortedNotebooks, editingNotebook: model.editingNotebook)
            updates = [.updateAllNotebooks(notebooks: notebookViewModels)]
            newModel = LibraryCoordinatorModel(notebooks: sortedNotebooks, editingNotebook: nil)
        case .didAddNotebook(let notebook):
            let updatedNotebooks = model.notebooks + [notebook]
            let sortedNotebooks = updatedNotebooks.sorted(by: defaultNotebookSorting)
            let notebookViewModels = viewModels(fromNotebooks: sortedNotebooks, editingNotebook: notebook)
            let indexOfNewNotebook = sortedNotebooks.index(of: notebook)!
            updates = [.addNotebook(index: indexOfNewNotebook, notebooks: notebookViewModels)]
            newModel = LibraryCoordinatorModel(notebooks: sortedNotebooks, editingNotebook: notebook)
        case .didDelete(let notebook):
            let indexOfDeletedNotebook = model.notebooks.index(of: notebook)!
            let updatedNotebooks = model.notebooks.removeWithoutMutation(at: indexOfDeletedNotebook)
            let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
            updates = [.deleteNotebook(index: indexOfDeletedNotebook, notebooks: notebookViewModels)]
            newModel = LibraryCoordinatorModel(notebooks: updatedNotebooks, editingNotebook: model.editingNotebook)
        case .didUpdate(let notebook):
            let indexOfUpdatedNotebook = model.notebooks.index(of: notebook)!
            var updatedNotebooks = model.notebooks
            updatedNotebooks[indexOfUpdatedNotebook] = notebook
            updatedNotebooks = updatedNotebooks.sorted(by: defaultNotebookSorting)
            let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
            updates = [.updateAllNotebooks(notebooks: notebookViewModels)]
            newModel = LibraryCoordinatorModel(notebooks: updatedNotebooks, editingNotebook: nil)
        case .failedToAddNotebook(let error):
            let errorMessage = error.error.localizedDescription
            let notebookViewModels = viewModels(fromNotebooks: model.notebooks)
            updates = [
                .updateAllNotebooks(notebooks: notebookViewModels),
                .showError(error: "Failed to add notebook", message: errorMessage)
            ]
            newModel = LibraryCoordinatorModel(notebooks: model.notebooks, editingNotebook: nil)
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

        return LibraryEvaluatorResult(updates: updates, actions: actions, model: newModel)
    }

    private static func viewModels(fromNotebooks: [Notebook], editingNotebook: Notebook? = nil) -> [NotebookCellViewModel] {
        return fromNotebooks.map {
            NotebookCellViewModel(title: $0.name, isEditable: $0 == editingNotebook)
        }
    }

    private static func defaultNotebookSorting(leftNotebook: Notebook, rightNotebook: Notebook) -> Bool {
        return leftNotebook.name < rightNotebook.name
    }
}
