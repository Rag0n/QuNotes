//
//  LibraryCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result

enum LibraryCoordinatorAction {
    case addNotebook
    case deleteNotebook(notebook: Notebook)
    case updateNotebook(notebook: Notebook, title: String)
    case showNotes(forNotebook: Notebook)
}

enum NotebookUseCaseEvent {
    case updateNotebooks(notebooks: [Notebook])
    case addNotebook(notebook: Notebook)
    case failedToAddNotebook(error: String)
}

struct LibraryCoordinatorModel {
    let notebooks: [Notebook]
    let editingNotebook: Notebook?
}

class LibraryCoordinator: Coordinator {
    // MARK: - Coordinator

    func onStart() {
        let notebooks = notebookUseCase.getAll()
        dispatch(event: NotebookUseCaseEvent.updateNotebooks(notebooks: notebooks))
    }

    var rootViewController: UIViewController {
        get {
            return libraryViewController
        }
    }

    // MARK: - Life cycle

    typealias Dependencies = HasNotebookUseCase & NotebookCoordinator.Dependencies
    fileprivate let notebookUseCase: NotebookUseCase
    fileprivate let dependencies: Dependencies
    fileprivate lazy var libraryViewController: LibraryViewController = {
        let vc = LibraryViewController()
        vc.inject(dispatch: dispatch)
        return vc
    }()
    fileprivate let navigationController: NavigationController
    fileprivate var activeNote: Note?
    fileprivate var editableNotebook: Notebook?
    fileprivate var notebooks = [Notebook]()

    fileprivate var model: LibraryCoordinatorModel

    init(withNavigationController navigationController: NavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.notebookUseCase = dependencies.notebookUseCase
        self.dependencies = dependencies

        self.model = LibraryCoordinatorModel(notebooks: [], editingNotebook: nil)
    }

    // MARK: - Private

    fileprivate func dispatch(event: LibraryViewControllerEvent) {
        let result = evaluate(event: event, model: model)
        model = result.model
        result.actions.forEach{ perform(action: $0) }
        result.updates.forEach { libraryViewController.apply(update: $0) }
    }

    fileprivate func dispatch(event: NotebookUseCaseEvent) {
        let result = evaluateUseCase(event: event, model: model)
        model = result.model
        result.actions.forEach{ perform(action: $0) }
        result.updates.forEach { libraryViewController.apply(update: $0) }
    }

    fileprivate func perform(action: LibraryCoordinatorAction) {
        switch action {
        case .addNotebook:
            switch notebookUseCase.add(withName: "") {
            case let .success(notebook):
                dispatch(event: NotebookUseCaseEvent.addNotebook(notebook: notebook))
            case let .failure(error):
                dispatch(event: NotebookUseCaseEvent.failedToAddNotebook(error: String(describing: error)))
            }
            return
        case .deleteNotebook(let notebook):
            return
        case .showNotes(let notebook):
            let notebookCoordinator = NotebookCoordinator(withNavigationController: navigationController,
                                                          dependencies: dependencies,
                                                          notebook: notebook)
            // TODO: add onDispose
            navigationController.pushCoordinator(coordinator: notebookCoordinator, animated: true)
            return
        case .updateNotebook(let notebook, let title):
            return
        }
    }

    fileprivate func updateLibraryViewController() {
        notebooks = notebookUseCase.getAll().sorted(by: { $0.name < $1.name })
        let libraryVM = LibraryViewModel(notebooks: notebooks.map(notebookCellViewModel))
        libraryViewController.render(withViewModel: libraryVM)
    }

    private func notebookCellViewModel(fromNotebook notebook: Notebook) -> NotebookCellViewModel {
        return NotebookCellViewModel(title: notebook.name,
                                     isEditable: notebook.uuid == self.editableNotebook?.uuid)
    }
}

// MARK: - LibraryViewControllerHandler

extension LibraryCoordinator: LibraryViewControllerHandler {
    func didTapAddNotebook() {
        _ = notebookUseCase.add(withName: "")
            .map(setEditableNotebook)
            .map { _ in self.updateLibraryViewController() }
    }

    func didTapOnNotebook(withIndex index: Int) {
        guard let notebook = notebook(forIndex: index) else { return }
        showNotes(forNotebook: notebook)
    }
    
    func didSwapeToDeleteNotebook(withIndex index: Int) -> Bool {
        guard let notebook = notebook(forIndex: index) else { return false }
        guard notebookUseCase.delete(notebook).error == nil else { return false }
        updateLibraryViewController()
        return true;
    }

    func didChangeNameOfNotebook(withIndex index: Int, title: String) {
        guard let notebook = notebook(forIndex: index) else { return }
        _ = notebookUseCase.update(notebook, name: title)
            .map(resetEditableNotebook)
            .map { _ in self.updateLibraryViewController() }
    }

    private func notebook(forIndex index: Int) -> Notebook? {
        guard (index < notebooks.count) else { return nil }
        return notebooks[index]
    }

    private func setEditableNotebook(notebook: Notebook) -> Notebook {
        editableNotebook = notebook
        return notebook
    }

    private func resetEditableNotebook(notebook: Notebook) -> Notebook {
        editableNotebook = nil
        return notebook
    }

    private func showNotes(forNotebook notebook: Notebook) {
        let notebookCoordinator = NotebookCoordinator(withNavigationController: navigationController, dependencies: dependencies, notebook: notebook)
        navigationController.pushCoordinator(coordinator: notebookCoordinator, animated: true, onDispose: updateLibraryViewController)
    }
}
