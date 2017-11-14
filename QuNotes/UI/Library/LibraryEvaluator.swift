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

        let notebookMetas: [Experimental.Notebook.Meta]

        init(notebooks: [Notebook], editingNotebook: Notebook?, notebookMetas: [Experimental.Notebook.Meta] = []) {
            self.notebooks = notebooks
            self.editingNotebook = editingNotebook
            self.notebookMetas = notebookMetas
        }
    }
    
    enum Action {
        case addNotebook(notebook: Experimental.Notebook.Model)
        case deleteNotebook(notebook: Experimental.Notebook.Meta)
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
        case didAddNotebook2(notebook: Experimental.Notebook.Meta, error: Error?)
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
        static var uuidGenerator: () -> String = { UUID().uuidString }
        let effects: [ViewControllerEffect]
        let actions: [Action]
        let model: Model

        init() {
            effects = []
            actions = []
            model = Model(notebooks: [], editingNotebook: nil)
        }

        // TODO: make fileprivate
        init(effects: [ViewControllerEffect], actions: [Action], model: Model) {
            self.effects = effects
            self.actions = actions
            self.model = model
        }

        func evaluate(event: ViewControllerEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewControllerEffect] = []
            var newModel = model

            switch event {
            case .addNotebook:
                let notebook = Experimental.Notebook.Model(uuid: Evaluator.uuidGenerator(), name: "", notes: [])
                let meta = Experimental.Notebook.Meta(uuid: notebook.uuid, name: notebook.name)
                let updatedNotebookMetas = model.notebookMetas + [meta]
                let sortedNotebookMetas = updatedNotebookMetas.sorted(by: notebookNameSorting)
                let indexOfNewNotebook = sortedNotebookMetas.index(of: meta)!
                let notebookViewModels = viewModels(fromNotebooks: sortedNotebookMetas)
                newModel = Model(notebooks: model.notebooks,
                                 editingNotebook: model.editingNotebook,
                                 notebookMetas: sortedNotebookMetas)
                effects = [.addNotebook(index: indexOfNewNotebook, notebooks: notebookViewModels)]
                actions = [.addNotebook(notebook: notebook)]
            case .deleteNotebook(let index):
                guard index < model.notebookMetas.count else { break }
                let notebookMeta = model.notebookMetas[index]
                let updatedNotebookMetas = model.notebookMetas.removeWithoutMutation(at: index)
                let notebookViewModels = viewModels(fromNotebooks: updatedNotebookMetas)
                effects = [.deleteNotebook(index: 0, notebooks: notebookViewModels)]
                newModel = Model(notebooks: model.notebooks,
                                 editingNotebook: model.editingNotebook,
                                 notebookMetas: updatedNotebookMetas)
                actions = [.deleteNotebook(notebook: notebookMeta)]
            case .selectNotebook(let index):
                let notebook = model.notebooks[index]
                actions = [.showNotes(forNotebook: notebook)]
            case .updateNotebook(let index, let title):
                let notebook = model.notebooks[index]
                actions = [.updateNotebook(notebook: notebook, title: title ?? "")]
            }

            return Evaluator(effects: effects, actions: actions, model: newModel)
        }

        func evaluate(event: CoordinatorEvent) -> Evaluator {
            var actions: [Action] = []
            var effects: [ViewControllerEffect] = []
            var newModel = model

            switch event {
            case let .didAddNotebook2(notebook, error):
                guard let error = error else { break }
                let updatedNotebooks = model.notebookMetas.removeWithoutMutation(object: notebook)
                newModel = Model(notebooks: model.notebooks,
                                 editingNotebook: model.editingNotebook,
                                 notebookMetas: updatedNotebooks)
                let updatedViewModels = viewModels(fromNotebooks: updatedNotebooks)
                effects = [.updateAllNotebooks(notebooks: updatedViewModels)]
                actions = [.showError(title: "Failed to add notebook", message: error.localizedDescription)]
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

    static func viewModels(fromNotebooks: [Experimental.Notebook.Meta]) -> [NotebookViewModel] {
        return fromNotebooks.map {
            NotebookViewModel(title: $0.name, isEditable: false)
        }
    }

    static func notebookNameSorting(leftNotebook: Notebook, rightNotebook: Notebook) -> Bool {
        return leftNotebook.name.lowercased() < rightNotebook.name.lowercased()
    }

    static func notebookNameSorting(lhs: Experimental.Notebook.Meta, rhs: Experimental.Notebook.Meta) -> Bool {
        return lhs.name.lowercased() < rhs.name.lowercased()
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

// MARK: - Equatables

extension UI.Library.ViewControllerEffect: Equatable {
    static func ==(lhs: UI.Library.ViewControllerEffect, rhs: UI.Library.ViewControllerEffect) -> Bool {
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
}

extension UI.Library.Action: Equatable {
    static func ==(lhs: UI.Library.Action, rhs: UI.Library.Action) -> Bool {
        switch (lhs, rhs) {
        case let (.addNotebook(lNotebook), .addNotebook(rNotebook)):
            return lNotebook == rNotebook
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
}

extension UI.Library.Model: Equatable {
    static func==(lhs: UI.Library.Model, rhs: UI.Library.Model) -> Bool {
        return (
            lhs.notebooks == rhs.notebooks &&
            lhs.editingNotebook == rhs.editingNotebook &&
            lhs.notebookMetas == rhs.notebookMetas
        )
    }
}

extension UI.Library.NotebookViewModel: Equatable {
    static func ==(lhs: UI.Library.NotebookViewModel, rhs: UI.Library.NotebookViewModel) -> Bool {
        return (lhs.title == rhs.title) && (lhs.isEditable == rhs.isEditable)
    }
}
