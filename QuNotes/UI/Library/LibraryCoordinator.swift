//
//  LibraryCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class LibraryCoordinator: Coordinator {
    // MARK: - Coordinator

    func onStart() {
        updateLibraryViewController()
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
        vc.inject(handler: self)
        return vc
    }()
    fileprivate let navigationController: NavigationController
    fileprivate var activeNote: Note?
    fileprivate var editableNotebook: Notebook?
    fileprivate var notebooks = [Notebook]()

    init(withNavigationController navigationController: NavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.notebookUseCase = dependencies.notebookUseCase
        self.dependencies = dependencies
    }

    // MARK: - Private

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
        navigationController.pushCoordinator(coordinator: notebookCoordinator, animated: true)
    }
}
