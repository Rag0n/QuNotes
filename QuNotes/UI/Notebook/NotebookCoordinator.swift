//
//  NotebookCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result

extension UI.Notebook {
    class CoordinatorImp: Coordinator {
        // MARK: - Coordinator

        func onStart() {
            // TODO: load notes for notebook meta
        }

        var rootViewController: UIViewController {
            get {
                return notebookViewController
            }
        }

        // MARK: - Life cycle

        typealias Dependencies = HasNoteUseCase
        fileprivate let dependencies: Dependencies
        fileprivate let navigationController: NavigationController
        fileprivate var evaluator: Evaluator!
        fileprivate var notebookEvaluator: Notebook.Evaluator

        fileprivate lazy var notebookViewController: NotebookViewController = {
            let vc = NotebookViewController(withDispatch: dispatch)
            vc.navigationItem.largeTitleDisplayMode = .never
            return vc
        }()

        init(withNavigationController navigationController: NavigationController, dependencies: Dependencies, notebook: Notebook.Meta) {
            self.navigationController = navigationController
            self.dependencies = dependencies
            self.notebookEvaluator = Notebook.Evaluator(model: Notebook.Model(meta: notebook, notes: []))
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewControllerEvent) {
            event |> evaluator.evaluate |> updateEvaluator
        }

        fileprivate func dispatch(event: CoordinatorEvent) {
            event |> evaluator.evaluate |> updateEvaluator
        }

        fileprivate func dispatchToNotebook(event: Notebook.InputEvent) {
            event |> notebookEvaluator.evaluate |> updateNotebook
        }

        fileprivate func updateEvaluator(evaluator: Evaluator) {
            self.evaluator = evaluator
            evaluator.actions.forEach(perform)
            evaluator.effects.forEach(notebookViewController.perform)
        }

        fileprivate func updateNotebook(notebook: Notebook.Evaluator) {
            self.notebookEvaluator = notebook
            notebook.actions.forEach(perform)
        }

        fileprivate func perform(action: Action) {
        }

        fileprivate func perform(action: Notebook.Action) {
        }
    }

    typealias ViewControllerDispacher = (_ event: UI.Notebook.ViewControllerEvent) -> ()
}
