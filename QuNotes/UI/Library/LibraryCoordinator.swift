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
            dispatch <| .didUpdateNotebooks(notebooks: notebooks)
            dispatch <| .loadNotebooks
        }

        var rootViewController: UIViewController {
            get {
                return libraryViewController
            }
        }

        // MARK: - Life cycle

        typealias Dependencies = HasNotebookUseCase & HasFileExecuter & UI.Notebook.CoordinatorImp.Dependencies
        fileprivate let notebookUseCase: NotebookUseCase
        fileprivate let fileExecuter: FileExecuter
        fileprivate let dependencies: Dependencies
        fileprivate let navigationController: NavigationController
        fileprivate var evaluator: Evaluator

        fileprivate lazy var libraryViewController: LibraryViewController = {
            return LibraryViewController(withDispatch: dispatch)
        }()

        private(set) var library: Experimental.Library.Evaluator

        init(withNavigationController navigationController: NavigationController, dependencies: Dependencies) {
            self.navigationController = navigationController
            self.notebookUseCase = dependencies.notebookUseCase
            self.dependencies = dependencies
            evaluator = Evaluator()

            let initialModel = Experimental.Library.Model(notebooks: [])
            library = Experimental.Library.Evaluator(model: initialModel)
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewControllerEvent) {
            updateEvaluator <| evaluator.evaluate(event: event)
        }

        fileprivate func dispatch(event: CoordinatorEvent) {
            updateEvaluator <| evaluator.evaluate(event: event)
        }

        fileprivate func dispatch(event: Experimental.Library.InputEvent) {
            updateLibrary <| library.evaluate(event: event)
        }

        fileprivate func updateEvaluator(evaluator: Evaluator) {
            self.evaluator = evaluator
            evaluator.actions.forEach(perform)
            evaluator.effects.forEach(libraryViewController.perform)
        }

        fileprivate func updateLibrary(library: Experimental.Library.Evaluator) {
            self.library = library
            library.actions.forEach(perform)
        }

        fileprivate func perform(action: Action) {
            switch action {
            case .addNotebook:
                let result = notebookUseCase.add(withName: "")
                dispatch <| .didAddNotebook(result: result)
            case .updateNotebook(let notebook, let title):
                let result = notebookUseCase.update(notebook, name: title)
                dispatch <| .didUpdateNotebook(result: result)
            case .deleteNotebook(let notebook):
                let result = notebookUseCase.delete(notebook)
                dispatch <| .didDeleteNotebook(result: result)
            case let .showError(title, message):
                showError(title: title, message: message, controller: libraryViewController)
            case .showNotes(let notebook):
                let notebookCoordinator = UI.Notebook.CoordinatorImp(withNavigationController: navigationController,
                                                                     dependencies: dependencies,
                                                                     notebook: notebook)
                navigationController.pushCoordinator(coordinator: notebookCoordinator, animated: true) { [unowned self] in
                    self.onStart()
                }
            }
        }

        fileprivate func perform(action: Experimental.Library.Action) {
            switch action {
            case let .createFile(url, content):
                return
            case let .deleteFile(url):
                return
            case let .readFiles(url, ext):
                return
            }
        }
    }
}
