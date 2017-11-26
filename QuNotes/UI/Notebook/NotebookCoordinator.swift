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
        fileprivate var evaluator: Evaluator!

        fileprivate lazy var notebookViewController: NotebookViewController = {
            let vc = NotebookViewController(withDispatch: dispatch)
            vc.navigationItem.largeTitleDisplayMode = .never
            return vc
        }()
        fileprivate var activeNote: UseCase.Note?

        init(withNavigationController navigationController: NavigationController, dependencies: Dependencies, notebook: Notebook.Meta) {
            self.navigationController = navigationController
            self.noteUseCase = dependencies.noteUseCase
            self.notebookUseCase = dependencies.notebookUseCase
            self.dependencies = dependencies
            // TODO: initialize eveluator
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
            case let .showError(title, message):
                showError(title: title, message: message, controller: notebookViewController)
            case let .showNote(note, isNewNote):
                let noteCoordinator = UI.Note.CoordinatorImp(withNavigationController: navigationController,
                                                             dependencies: dependencies,
                                                             note: note,
                                                             isNewNote: isNewNote)
                navigationController.pushCoordinator(coordinator: noteCoordinator,
                                                     animated: true) { [unowned self] in
                    self.onStart()
                }
            }
        }
    }
}
