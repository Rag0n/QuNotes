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
            actions = [LibraryCoordinatorAction.addNotebook]
        case .deleteNotebook(let index):
            let notebook = model.notebooks[index]
            actions = [LibraryCoordinatorAction.deleteNotebook(notebook: notebook)]
        case .selectNotebook(let index):
            let notebook = model.notebooks[index]
            actions = [LibraryCoordinatorAction.showNotes(forNotebook: notebook)]
        case .updateNotebook(let index, let title):
            let notebook = model.notebooks[index]
            actions = [LibraryCoordinatorAction.updateNotebook(notebook: notebook, title: title)]
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
            updates = [LibraryViewControllerUpdate.updateAllNotebooks(notebooks: notebookViewModels)]
            newModel = LibraryCoordinatorModel(notebooks: sortedNotebooks, editingNotebook: nil)
        case .didAddNotebook(let notebook):
            let updatedNotebooks = model.notebooks + [notebook]
            let sortedNotebooks = updatedNotebooks.sorted(by: defaultNotebookSorting)
            let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks, editingNotebook: notebook)
            let indexOfNewNotebook = sortedNotebooks.index(of: notebook)!
            updates = [LibraryViewControllerUpdate.addNotebook(index: indexOfNewNotebook, notebooks: notebookViewModels)]
            newModel = LibraryCoordinatorModel(notebooks: sortedNotebooks, editingNotebook: notebook)
        case .didDelete(let notebook):
            let indexOfDeletedNotebook = model.notebooks.index(of: notebook)!
            let updatedNotebooks = model.notebooks.removeWithoutMutation(at: indexOfDeletedNotebook)
            let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
            updates = [LibraryViewControllerUpdate.deleteNotebook(index: indexOfDeletedNotebook, notebooks: notebookViewModels)]
            newModel = LibraryCoordinatorModel(notebooks: updatedNotebooks, editingNotebook: model.editingNotebook)
        case .didUpdate(let notebook):
            let indexOfUpdatedNotebook = model.notebooks.index(of: notebook)!
            var updatedNotebooks = model.notebooks
            updatedNotebooks[indexOfUpdatedNotebook] = notebook
            updatedNotebooks = updatedNotebooks.sorted(by: defaultNotebookSorting)
            let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
            updates = [LibraryViewControllerUpdate.updateAllNotebooks(notebooks: notebookViewModels)]
            newModel = LibraryCoordinatorModel(notebooks: updatedNotebooks, editingNotebook: nil)
        case .failedToAddNotebook(let error):
            let _ = String(describing: error)
            // TODO: Add error update
        case .failedToDeleteNotebook(let error):
            let _ = String(describing: error)
            // TODO: Add error update
        case .failedToUpdateNotebook(let error):
            let _ = String(describing: error)
            // TODO: Add error update
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
