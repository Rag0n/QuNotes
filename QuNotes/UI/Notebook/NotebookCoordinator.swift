//
//  NotebookCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result

extension UI {
    enum Notebook {}
}

extension UI.Notebook {
    typealias ViewControllerDispacher = (_ event: UI.Notebook.ViewControllerEvent) -> ()
    
    class CoordinatorImp: Coordinator {
        // MARK: - Coordinator

        func onStart() {
            let notes = noteUseCase.getAll()
            dispatch <| .didUpdateNotes(notes: notes)
        }

        var rootViewController: UIViewController {
            get {
                return notebookViewController
            }
        }

        // MARK: - Life cycle

        typealias Dependencies = HasNoteUseCase & HasNotebookUseCase
        fileprivate let noteUseCase: NoteUseCase
        fileprivate let notebookUseCase: NotebookUseCase
        fileprivate let dependencies: Dependencies
        fileprivate let navigationController: NavigationController
        fileprivate var evaluator: Evaluator

        fileprivate lazy var notebookViewController: NotebookViewController = {
            let vc = NotebookViewController()
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.inject(dispatch: dispatch)
            return vc
        }()
        fileprivate var activeNote: Note?

        init(withNavigationController navigationController: NavigationController, dependencies: Dependencies, notebook: Notebook) {
            self.navigationController = navigationController
            self.noteUseCase = dependencies.noteUseCase
            self.notebookUseCase = dependencies.notebookUseCase
            self.dependencies = dependencies
            evaluator = Evaluator(withNotebook: notebook)
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
            evaluator.effects.forEach(notebookViewController.perform)
        }

        fileprivate func perform(action: Action) {
            switch action {
            case .addNote:
                let result = noteUseCase.add(withTitle: "")
                dispatch <| .didAddNote(result: result)
            case .deleteNote(let note):
                let result = noteUseCase.delete(note)
                dispatch <| .didDeleteNote(result: result)
            case .updateNotebook(let notebook, let title):
                let result = notebookUseCase.update(notebook, name: title)
                dispatch <| .didUpdateNotebook(result: result)
            case .deleteNotebook(let notebook):
                let result = notebookUseCase.delete(notebook)
                dispatch <| .didDeleteNotebook(error: result.error)
            case .finish:
                navigationController.popViewController(animated: true)
            case .showNote(let note):
                let noteCoordinator = UI.Note.CoordinatorImp(withNavigationController: navigationController,
                                                             dependencies: dependencies,
                                                             note: note)
                navigationController.pushCoordinator(coordinator: noteCoordinator,
                                                     animated: true) { [unowned self] in
                    self.onStart()
                }
            }
        }
    }
}
