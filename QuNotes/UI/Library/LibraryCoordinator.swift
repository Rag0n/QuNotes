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
    fileprivate let dependencies: Dependencies
    fileprivate lazy var libraryViewController: LibraryViewController = {
        let vc = LibraryViewController()
        return vc
    }()
    fileprivate let navigationController: NavigationController
    fileprivate var activeNote: Note?

    init(withNavigationController navigationController: NavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: - Private

    fileprivate func updateLibraryViewController() {
        let notebooks = dependencies.notebookUseCase.getAll()
        let libraryVM = LibraryViewModel(notebooks: notebooks.map { $0.name })
        libraryViewController.render(withViewModel: libraryVM)
    }
}
