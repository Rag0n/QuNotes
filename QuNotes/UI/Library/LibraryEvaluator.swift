//
//  LibraryEvaluator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 08.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

struct LibraryEvaluatorResult {
    let updates: [LibraryViewControllerUpdate]
    let actions: [LibraryCoordinatorAction]
    let model: LibraryCoordinatorModel
}
func evaluate(event: LibraryViewControllerEvent, model: LibraryCoordinatorModel) -> LibraryEvaluatorResult {
    switch event {
    case .addNotebook:
        return LibraryEvaluatorResult(updates: [], actions: [], model: LibraryCoordinatorModel(notebooks: []))
    case .deleteNotebook:
        return LibraryEvaluatorResult(updates: [], actions: [], model: LibraryCoordinatorModel(notebooks: []))
    case .selectNotebook:
        return LibraryEvaluatorResult(updates: [], actions: [], model: LibraryCoordinatorModel(notebooks: []))
    }
}

func evaluateUseCase(event: NotebookUseCaseEvent, model: LibraryCoordinatorModel) -> LibraryEvaluatorResult {
    switch event {
    case .updateNotebooks(let notebooks):
        let notebookViewModels = notebooks.map {
            return NotebookCellViewModel(title: $0.name, isEditable: false)
        }
        let updates = [LibraryViewControllerUpdate.updateAllNotebooks(notebooks: notebookViewModels)]
        let model = LibraryCoordinatorModel(notebooks: notebooks)
        return LibraryEvaluatorResult(updates: updates, actions: [], model: model)
    case .addNotebook:
        return LibraryEvaluatorResult(updates: [], actions: [], model: LibraryCoordinatorModel(notebooks: []))
    case .failedToAddNotebook(let error):
        return LibraryEvaluatorResult(updates: [], actions: [], model: LibraryCoordinatorModel(notebooks: []))
    }
}
