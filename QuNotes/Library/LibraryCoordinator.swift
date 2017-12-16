//
//  LibraryCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result
import Core
import Prelude

extension Library {
    final class CoordinatorImp: Coordinator {
        // MARK: - Coordinator

        func onStart() {
            dispatchToLibrary <| .loadNotebooks
        }

        var viewController: UIViewController {
            return libraryViewController
        }

        // MARK: - Life cycle

        typealias Dependencies = HasFileExecuter & Notebook.CoordinatorImp.Dependencies

        init(withNavigationController navigationController: NavigationController, dependencies: Dependencies) {
            self.navigationController = navigationController
            self.fileExecuter = dependencies.fileExecuter
            self.dependencies = dependencies
            evaluator = Evaluator()
            libraryEvaluator = Core.Library.Evaluator(model: Core.Library.Model(notebooks: []))
        }

        // MARK: - Private

        fileprivate func perform(action: Action) {
            switch action {
            case let .addNotebook(notebook):
                dispatchToLibrary <| .addNotebook(notebook: notebook)
            case let .deleteNotebook(notebook):
                dispatchToLibrary <| .removeNotebook(notebook: notebook)
            case let .updateNotebook(notebook):
                return
            case let .reloadNotebook(notebook):
                return
            case let .showError(title, message):
                showError(title: title, message: message)
            case let .showNotebook(notebook):
                let notebookCoordinator = Notebook.CoordinatorImp(withNavigationController: navigationController,
                                                                     dependencies: dependencies,
                                                                     notebook: notebook)
                navigationController.pushCoordinator(coordinator: notebookCoordinator, animated: true) { [unowned self] in
                    self.dispatch <| .didFinishShowing(notebook: notebook)
                }
            }
        }

        fileprivate func perform(action: Core.Library.Effect) {
            switch action {
            case let .createNotebook(notebook, url):
                let error = fileExecuter.createFile(atURL: url, content: notebook.meta)
                dispatchToLibrary <| .didAddNotebook(notebook: notebook, error: error)
                dispatch <| .didAddNotebook(notebook: notebook.meta, error: error)
            case let .deleteNotebook(notebook, url):
                let error = fileExecuter.deleteDirectory(at: url)
                dispatchToLibrary <| .didRemoveNotebook(notebook: notebook, error: error)
                dispatch <| .didDeleteNotebook(notebook: notebook.meta, error: error)
            case .readBaseDirectory:
                let result = fileExecuter.contentOfDocumentsFolder()
                dispatchToLibrary <| .didReadBaseDirectory(urls: result)
            case let .readNotebooks(urls):
                let results = urls.map { fileExecuter.readFile(at: $0, contentType: Core.Notebook.Meta.self) }
                dispatchToLibrary <| .didReadNotebooks(notebooks: results)
            case let .handleError(title, message):
                showError(title: title, message: message)
            case .didLoadNotebooks(let notebooks):
                dispatch <| .didLoadNotebooks(notebooks: notebooks)
            }
        }

        // MARK: State

        fileprivate let fileExecuter: FileExecuter
        fileprivate let dependencies: Dependencies
        fileprivate let navigationController: NavigationController
        fileprivate var evaluator: Evaluator
        fileprivate var libraryEvaluator: Core.Library.Evaluator

        fileprivate lazy var libraryViewController: LibraryViewController = {
            return LibraryViewController(withDispatch: dispatch)
        }()

        // MARK: Utility

        fileprivate func dispatch(event: ViewEvent) {
            updateEvaluator <| evaluator.evaluate(event: event)
        }

        fileprivate func dispatch(event: CoordinatorEvent) {
            updateEvaluator <| evaluator.evaluate(event: event)
        }

        fileprivate func dispatchToLibrary(event: Core.Library.Event) {
            updateLibrary <| libraryEvaluator.evaluate(event: event)
        }

        fileprivate func updateEvaluator(evaluator: Evaluator) {
            self.evaluator = evaluator
            evaluator.actions.forEach(perform)
            evaluator.effects.forEach(libraryViewController.perform)
        }

        fileprivate func updateLibrary(library: Core.Library.Evaluator) {
            self.libraryEvaluator = library
            library.effects.forEach(perform)
        }
    }
}
