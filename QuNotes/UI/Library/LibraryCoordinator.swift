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

    typealias Dependencies = HasNotebookUseCase
    fileprivate let notebookUseCase: NotebookUseCase
    fileprivate lazy var libraryViewController: LibraryViewController = {
        let vc = LibraryViewController()
        vc.inject(handler: self)
        return vc
    }()
    fileprivate let navigationController: NavigationController
    fileprivate var activeNote: Note?
    fileprivate var editableNotebook: Notebook?

    init(withNavigationController navigationController: NavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.notebookUseCase = dependencies.notebookUseCase
    }

    // MARK: - Private

    fileprivate func updateLibraryViewController() {
        let notebooks = notebookUseCase.getAll()
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
        _ = notebookUseCase.add(withName: "Notebook fixture")
            .map(setEditableNotebook)
            .map { _ in self.updateLibraryViewController() }
    }

    func didTapOnNotebook(withIndex index: Int) {

    }
    
    func didSwapeToDeleteNotebook(withIndex index: Int) -> Bool {
        guard deleteNotebook(withIndex: index) else { return false }
        updateLibraryViewController()
        return true;
    }

    private func deleteNotebook(withIndex index: Int) -> Bool {
        let notebooks = notebookUseCase.getAll()
        guard (index < notebooks.count) else { return false }
        return notebookUseCase.delete(notebooks[index]).error == nil
    }

    private func setEditableNotebook(notebook: Notebook) -> Notebook {
        editableNotebook = notebook
        return notebook
    }
}
