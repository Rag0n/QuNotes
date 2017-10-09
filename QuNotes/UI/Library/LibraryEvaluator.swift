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
        switch event {
        case .addNotebook:
            let actions = [LibraryCoordinatorAction.addNotebook]
            return LibraryEvaluatorResult(updates: [], actions: actions, model: model)
        case .deleteNotebook(let index):
            let notebook = model.notebooks[index]
            let actions = [LibraryCoordinatorAction.deleteNotebook(notebook: notebook)]
            return LibraryEvaluatorResult(updates: [], actions: actions, model: model)
        case .selectNotebook(let index):
            let notebook = model.notebooks[index]
            let actions = [LibraryCoordinatorAction.showNotes(forNotebook: notebook)]
            return LibraryEvaluatorResult(updates: [], actions: actions, model: model)
        case .updateNotebook(let index, let title):
            let notebook = model.notebooks[index]
            let actions = [LibraryCoordinatorAction.updateNotebook(notebook: notebook, title: title)]
            return LibraryEvaluatorResult(updates: [], actions: actions, model: model)
        }
    }
}

extension LibraryEvaluator {
    static func evaluateUseCase(event: NotebookUseCaseEvent, model: LibraryCoordinatorModel) -> LibraryEvaluatorResult {
        switch event {
        case .didUpdateNotebooks(let notebooks):
            let sortedNotebooks = notebooks.sorted(by: { $0.name < $1.name })
            let notebookViewModels = sortedNotebooks.map {
                return NotebookCellViewModel(title: $0.name, isEditable: $0 == model.editingNotebook)
            }
            let updates = [LibraryViewControllerUpdate.updateAllNotebooks(notebooks: notebookViewModels)]
            let model = LibraryCoordinatorModel(notebooks: sortedNotebooks, editingNotebook: nil)
            return LibraryEvaluatorResult(updates: updates, actions: [], model: model)
        case .didAddNotebook(let notebook):
            let updatedNotebooks = model.notebooks + [notebook]
            let sortedNotebooks = updatedNotebooks.sorted(by: { $0.name < $1.name })
            let notebookViewModels = sortedNotebooks.map {
                return NotebookCellViewModel(title: $0.name, isEditable: $0 == notebook)
            }
            let indexOfNewNotebook = sortedNotebooks.index(of: notebook)!
            let updates = [LibraryViewControllerUpdate.addNotebook(index: indexOfNewNotebook, notebooks: notebookViewModels)]
            let newModel = LibraryCoordinatorModel(notebooks: sortedNotebooks, editingNotebook: notebook)
            return LibraryEvaluatorResult(updates: updates, actions: [], model: newModel)
        case .didDelete(let notebook):
            let indexOfDeletedNotebook = model.notebooks.index(of: notebook)!
            var updatedNotebooks = model.notebooks
            updatedNotebooks.remove(at: indexOfDeletedNotebook)
            let notebookViewModels = updatedNotebooks.map {
                return NotebookCellViewModel(title: $0.name, isEditable: false)
            }
            let updates = [LibraryViewControllerUpdate.deleteNotebook(index: indexOfDeletedNotebook, notebooks: notebookViewModels)]
            let newModel = LibraryCoordinatorModel(notebooks: updatedNotebooks, editingNotebook: model.editingNotebook)
            return LibraryEvaluatorResult(updates: updates, actions: [], model: newModel)
        case .didUpdate(let notebook):
            let indexOfUpdatedNotebook = model.notebooks.index(of: notebook)!
            var updatedNotebooks = model.notebooks
            updatedNotebooks[indexOfUpdatedNotebook] = notebook
            updatedNotebooks = updatedNotebooks.sorted(by: { $0.name < $1.name })
            let notebookViewModels = updatedNotebooks.map {
                return NotebookCellViewModel(title: $0.name, isEditable: false)
            }
            let updates = [LibraryViewControllerUpdate.updateAllNotebooks(notebooks: notebookViewModels)]
            let newModel = LibraryCoordinatorModel(notebooks: updatedNotebooks, editingNotebook: nil)
            return LibraryEvaluatorResult(updates: updates, actions: [], model: newModel)
        case .failedToAddNotebook(let error):
            let errorString = String(describing: error)
            // TODO: Add error update
            return LibraryEvaluatorResult(updates: [], actions: [], model: model)
        case .failedToDeleteNotebook(let error):
            let errorString = String(describing: error)
            // TODO: Add error update
            return LibraryEvaluatorResult(updates: [], actions: [], model: model)
        case .failedToUpdateNotebook(let error):
            let errorString = String(describing: error)
            // TODO: Add error update
            return LibraryEvaluatorResult(updates: [], actions: [], model: model)
        }
    }
}
