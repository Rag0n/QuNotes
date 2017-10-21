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
    struct Model {
        let notebooks: [Notebook]
        let editingNotebook: Notebook?
    }
    
    enum Action {
        case addNotebook
        case deleteNotebook(notebook: Notebook)
        case updateNotebook(notebook: Notebook, title: String)
        case showNotes(forNotebook: Notebook)
    }

    enum ViewControllerEffect {
        case updateAllNotebooks(notebooks: [NotebookCellViewModel])
        case addNotebook(index: Int, notebooks: [NotebookCellViewModel])
        case updateNotebook(index: Int, notebooks:  [NotebookCellViewModel])
        case deleteNotebook(index: Int, notebooks: [NotebookCellViewModel])
        case showError(error: String, message: String)
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

    enum ViewControllerEvent {
        case addNotebook
        case selectNotebook(index: Int)
        case deleteNotebook(index: Int)
        case updateNotebook(index: Int, title: String?)
    }

    // MARK: - Evaluator

    struct Evaluator {
        let effects: [ViewControllerEffect]
        let actions: [Action]
        let model: Model

        init() {
            effects = []
            actions = []
            model = Model(notebooks: [], editingNotebook: nil)
        }

        private init(effects: [ViewControllerEffect], actions: [Action], model: Model) {
            self.effects = effects
            self.actions = actions
            self.model = model
        }

        func evaluate(event: ViewControllerEvent) -> Evaluator {
            var actions: [Action] = []
            let effects: [ViewControllerEffect] = []

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
                actions = [.updateNotebook(notebook: notebook, title: title ?? "")]
            }

            return Evaluator(effects: effects, actions: actions, model: model)
        }

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            let actions: [Action] = []
            var effects: [ViewControllerEffect] = []
            var newModel = model

            switch event {
            case .didUpdateNotebooks(let notebooks):
                let sortedNotebooks = notebooks.sorted(by: defaultNotebookSorting)
                let notebookViewModels = viewModels(fromNotebooks: sortedNotebooks, editingNotebook: model.editingNotebook)
                effects = [.updateAllNotebooks(notebooks: notebookViewModels)]
                newModel = Model(notebooks: sortedNotebooks, editingNotebook: nil)
            case .didAddNotebook(let notebook):
                let updatedNotebooks = model.notebooks + [notebook]
                let sortedNotebooks = updatedNotebooks.sorted(by: defaultNotebookSorting)
                let notebookViewModels = viewModels(fromNotebooks: sortedNotebooks, editingNotebook: notebook)
                let indexOfNewNotebook = sortedNotebooks.index(of: notebook)!
                effects = [.addNotebook(index: indexOfNewNotebook, notebooks: notebookViewModels)]
                newModel = Model(notebooks: sortedNotebooks, editingNotebook: notebook)
            case .didDelete(let notebook):
                let indexOfDeletedNotebook = model.notebooks.index(of: notebook)!
                let updatedNotebooks = model.notebooks.removeWithoutMutation(at: indexOfDeletedNotebook)
                let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
                effects = [.deleteNotebook(index: indexOfDeletedNotebook, notebooks: notebookViewModels)]
                newModel = Model(notebooks: updatedNotebooks, editingNotebook: model.editingNotebook)
            case .didUpdate(let notebook):
                let indexOfUpdatedNotebook = model.notebooks.index(of: notebook)!
                var updatedNotebooks = model.notebooks
                updatedNotebooks[indexOfUpdatedNotebook] = notebook
                updatedNotebooks = updatedNotebooks.sorted(by: defaultNotebookSorting)
                let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
                effects = [.updateAllNotebooks(notebooks: notebookViewModels)]
                newModel = Model(notebooks: updatedNotebooks, editingNotebook: nil)
            case .failedToAddNotebook(let error):
                let errorMessage = error.error.localizedDescription
                let notebookViewModels = viewModels(fromNotebooks: model.notebooks)
                effects = [
                    .updateAllNotebooks(notebooks: notebookViewModels),
                    .showError(error: "Failed to add notebook", message: errorMessage)
                ]
                newModel = Model(notebooks: model.notebooks, editingNotebook: nil)
            case .failedToDeleteNotebook(let error):
                let errorMessage = error.error.localizedDescription
                let notebookViewModels = viewModels(fromNotebooks: model.notebooks, editingNotebook: model.editingNotebook)
                effects = [
                    .updateAllNotebooks(notebooks: notebookViewModels),
                    .showError(error: "Failed to delete notebook", message: errorMessage)
                ]
            case .failedToUpdateNotebook(let error):
                let errorMessage = error.error.localizedDescription
                let notebookViewModels = viewModels(fromNotebooks: model.notebooks, editingNotebook: model.editingNotebook)
                effects = [
                    .updateAllNotebooks(notebooks: notebookViewModels),
                    .showError(error: "Failed to update notebook", message: errorMessage)
                ]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
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

// MARK: - ViewControllerEffect Equatable

extension UI.Library.ViewControllerEffect: Equatable {}

func ==(lhs: UI.Library.ViewControllerEffect, rhs: UI.Library.ViewControllerEffect) -> Bool {
    switch (lhs, rhs) {
    case (.updateAllNotebooks(let lNotebooks), .updateAllNotebooks(let rNotebooks)):
        return lNotebooks == rNotebooks
    case (.addNotebook(let lIndex, let lNotebooks), .addNotebook(let rIndex, let rNotebooks)):
        return (lIndex == rIndex) && (lNotebooks == rNotebooks)
    case (.updateNotebook(let lIndex, let lNotebooks), .updateNotebook(let rIndex, let rNotebooks)):
        return (lIndex == rIndex) && (lNotebooks == rNotebooks)
    case (.deleteNotebook(let lIndex, let lNotebooks), .deleteNotebook(let rIndex, let rNotebooks)):
        return (lIndex == rIndex) && (lNotebooks == rNotebooks)
    case (.showError(let lError, let lMessage), .showError(let rError, let rMessage)):
        return (lError == rError) && (lMessage == rMessage)
    default: return false
    }
}

// MARK: - Action Equtable

extension UI.Library.Action: Equatable {}

func ==(lhs: UI.Library.Action, rhs: UI.Library.Action) -> Bool {
    switch (lhs, rhs) {
    case (.addNotebook, .addNotebook):
        return true
    case (.deleteNotebook(let lNotebook), .deleteNotebook(let rNotebook)):
        return lNotebook == rNotebook
    case (.updateNotebook(let lNotebook, let lTitle), .updateNotebook(let rNotebook, let rTitle)):
        return (lNotebook == rNotebook) && (lTitle == rTitle)
    case (.showNotes(let lNotebook), .showNotes(let rNotebook)):
        return lNotebook == rNotebook
    default: return false
    }
}
