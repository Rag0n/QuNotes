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

    struct Model {
        let notebooks: [Notebook]
        let editingNotebook: Notebook?
    }
    
    enum Action {
        case addNotebook
        case deleteNotebook(notebook: Notebook)
        case updateNotebook(notebook: Notebook, title: String)
        case showNotes(forNotebook: Notebook)
        case showError(title: String, message: String)
    }

    enum ViewControllerEffect {
        case updateAllNotebooks(notebooks: [NotebookViewModel])
        case addNotebook(index: Int, notebooks: [NotebookViewModel])
        case updateNotebook(index: Int, notebooks:  [NotebookViewModel])
        case deleteNotebook(index: Int, notebooks: [NotebookViewModel])
    }

    enum CoordinatorEvent {
        case didUpdateNotebooks(notebooks: [Notebook])
        case didAddNotebook(result: Result<Notebook, AnyError>)
        case didUpdateNotebook(result: Result<Notebook, AnyError>)
        case didDeleteNotebook(result: Result<Notebook, AnyError>)
    }

    enum ViewControllerEvent {
        case addNotebook
        case selectNotebook(index: Int)
        case deleteNotebook(index: Int)
        case updateNotebook(index: Int, title: String?)
    }

    struct NotebookViewModel {
        let title: String
        let isEditable: Bool
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

        fileprivate init(effects: [ViewControllerEffect], actions: [Action], model: Model) {
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
                let sortedNotebooks = notebooks.sorted(by: notebookNameSorting)
                let notebookViewModels = viewModels(fromNotebooks: sortedNotebooks,
                                                    editingNotebook: nil)
                effects = [.updateAllNotebooks(notebooks: notebookViewModels)]
                newModel = Model(notebooks: sortedNotebooks, editingNotebook: nil)
            case .didAddNotebook(let result):
                guard case let .success(notebook) = result else {
                    return updateNotebooksAndShowError(notebooks: model.notebooks, error: result.error!, reason: "Failed to add notebook")
                }

                let updatedNotebooks = model.notebooks + [notebook]
                let sortedNotebooks = updatedNotebooks.sorted(by: notebookNameSorting)
                let notebookViewModels = viewModels(fromNotebooks: sortedNotebooks, editingNotebook: notebook)
                let indexOfNewNotebook = sortedNotebooks.index(of: notebook)!
                effects = [.addNotebook(index: indexOfNewNotebook, notebooks: notebookViewModels)]
                newModel = Model(notebooks: sortedNotebooks, editingNotebook: notebook)
            case .didDeleteNotebook(let result):
                guard case let .success(notebook) = result else {
                    return updateNotebooksAndShowError(notebooks: model.notebooks, error: result.error!, reason: "Failed to delete notebook")
                }

                let indexOfDeletedNotebook = model.notebooks.index(of: notebook)!
                let updatedNotebooks = model.notebooks.removeWithoutMutation(at: indexOfDeletedNotebook)
                let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
                effects = [.deleteNotebook(index: indexOfDeletedNotebook, notebooks: notebookViewModels)]
                newModel = Model(notebooks: updatedNotebooks, editingNotebook: nil)
            case .didUpdateNotebook(let result):
                guard case let .success(notebook) = result else {
                    return updateNotebooksAndShowError(notebooks: model.notebooks, error: result.error!, reason: "Failed to update notebook")
                }

                let indexOfUpdatedNotebook = model.notebooks.index(of: notebook)!
                var updatedNotebooks = model.notebooks
                updatedNotebooks[indexOfUpdatedNotebook] = notebook
                updatedNotebooks = updatedNotebooks.sorted(by: notebookNameSorting)
                let notebookViewModels = viewModels(fromNotebooks: updatedNotebooks)
                effects = [.updateAllNotebooks(notebooks: notebookViewModels)]
                newModel = Model(notebooks: updatedNotebooks, editingNotebook: nil)
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }
    }
}

// MARK: - Private

private extension UI.Library {
    static func viewModels(fromNotebooks: [Notebook], editingNotebook: Notebook? = nil) -> [NotebookViewModel] {
        return fromNotebooks.map {
            NotebookViewModel(title: $0.name, isEditable: $0 == editingNotebook)
        }
    }

    static func notebookNameSorting(leftNotebook: Notebook, rightNotebook: Notebook) -> Bool {
        return leftNotebook.name.lowercased() < rightNotebook.name.lowercased()
    }

    static func updateNotebooksAndShowError(notebooks: [Notebook], error: AnyError, reason: String) -> Evaluator {
        let errorMessage = error.error.localizedDescription
        let notebookViewModels = viewModels(fromNotebooks: notebooks)
        let actions: [Action] = [.showError(title: reason, message: errorMessage)]
        let effects: [ViewControllerEffect] = [.updateAllNotebooks(notebooks: notebookViewModels)]

        return Evaluator(effects: effects,
                         actions: actions,
                         model: Model(notebooks: notebooks, editingNotebook: nil))
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
    case (.showError(let lTitle, let lMessage), .showError(let rTitle, let rMessage)):
        return (lTitle == rTitle) && (lMessage == rMessage)
    default: return false
    }
}

// MARK: - NotebookViewModel Equatable

extension UI.Library.NotebookViewModel: Equatable {}

func ==(lhs: UI.Library.NotebookViewModel, rhs: UI.Library.NotebookViewModel) -> Bool {
    return (lhs.title == rhs.title) && (lhs.isEditable == rhs.isEditable)
}
