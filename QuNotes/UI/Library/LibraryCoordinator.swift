//
//  LibraryCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result

extension UI {
    enum Library {}
}

extension UI.Library {
    typealias ViewControllerDispacher = (_ event: ViewControllerEvent) -> ()

    class CoordinatorImp: Coordinator {
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

        typealias Dependencies = HasNotebookUseCase & UI.Notebook.CoordinatorImp.Dependencies
        fileprivate let notebookUseCase: NotebookUseCase
        fileprivate let dependencies: Dependencies
        fileprivate let navigationController: NavigationController
        fileprivate var evaluator: Evaluator

        fileprivate lazy var libraryViewController: LibraryViewController = {
            let vc = LibraryViewController()
            vc.inject(dispatch: dispatch)
            return vc
        }()

        init(withNavigationController navigationController: NavigationController, dependencies: Dependencies) {
            self.navigationController = navigationController
            self.notebookUseCase = dependencies.notebookUseCase
            self.dependencies = dependencies
            evaluator = Evaluator()
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewControllerEvent) {
            updateEvaluator <| evaluator.evaluate(event: event)
        }

        fileprivate func dispatch(event: CoordinatorEvent) {
            updateEvaluator <| evaluator.evaluate(event: event)
        }

        fileprivate func updateEvaluator(evaluator: Evaluator) {
            self.evaluator = evaluator
            evaluator.actions.forEach(perform)
            evaluator.effects.forEach(libraryViewController.apply)
        }

        fileprivate func perform(action: Action) {
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
                }
            case .showNotes(let notebook):
                let notebookCoordinator = UI.Notebook.CoordinatorImp(withNavigationController: navigationController,
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
                }
            }
        }
    }
}
