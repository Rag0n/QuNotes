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
    case didUpdateNotebooks(notebooks: [Notebook])
    case didAddNotebook(notebook: Notebook)
    case didDelete(notebook: Notebook)
    case didUpdate(notebook: Notebook)
    case failedToAddNotebook(error: AnyError)
    case failedToDeleteNotebook(error: AnyError)
    case failedToUpdateNotebook(error: AnyError)
}

struct LibraryCoordinatorModel {
    let notebooks: [Notebook]
    let editingNotebook: Notebook?
}

class LibraryCoordinator: Coordinator {
    // MARK: - Coordinator

    func onStart() {
        let notebooks = notebookUseCase.getAll()
        dispatch(event: .didUpdateNotebooks(notebooks: notebooks))
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
    fileprivate let navigationController: NavigationController
    fileprivate var model: LibraryCoordinatorModel

    fileprivate lazy var libraryViewController: LibraryViewController = {
        let vc = LibraryViewController()
        vc.inject(dispatch: dispatch)
        return vc
    }()

    init(withNavigationController navigationController: NavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.notebookUseCase = dependencies.notebookUseCase
        self.dependencies = dependencies
        self.model = initialModel()
    }

    // MARK: - Private

    fileprivate func dispatch(event: LibraryViewControllerEvent) {
        handleEvaluation <| evaluate(event: event, model: model)
    }

    fileprivate func dispatch(event: NotebookUseCaseEvent) {
        handleEvaluation <| evaluateUseCase(event: event, model: model)
    }

    fileprivate func handleEvaluation(result: LibraryEvaluatorResult) {
        model = result.model
        result.actions.forEach(perform)
        result.updates.forEach(libraryViewController.apply)
    }

    fileprivate func perform(action: LibraryCoordinatorAction) {
        switch action {
        case .addNotebook:
            switch notebookUseCase.add(withName: "") {
            case let .success(notebook):
                dispatch(event: .didAddNotebook(notebook: notebook))
            case let .failure(error):
                dispatch(event: .failedToAddNotebook(error: error))
            }
        case .deleteNotebook(let notebook):
            switch notebookUseCase.delete(notebook) {
            case let .success(notebook):
                dispatch(event: .didDelete(notebook: notebook))
            case let .failure(error):
                dispatch(event: .failedToDeleteNotebook(error: error))
                return
            }
        case .showNotes(let notebook):
            let notebookCoordinator = NotebookCoordinator(withNavigationController: navigationController,
                                                          dependencies: dependencies,
                                                          notebook: notebook)
            navigationController.pushCoordinator(coordinator: notebookCoordinator, animated: true) { [unowned self] in
                self.onStart()
            }
        case .updateNotebook(let notebook, let title):
            switch notebookUseCase.update(notebook, name: title) {
            case let .success(notebook):
                dispatch(event: .didUpdate(notebook: notebook))
            case let .failure(error):
                dispatch(event: .failedToUpdateNotebook(error: error))
                return
            }
        }
    }
}
