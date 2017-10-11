//
//  NotebookCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result

enum NotebookNamespace {}

extension NotebookNamespace {
    enum Action {
    }

    enum NoteUseCaseEvent {
    }

    struct Model {
    }

    class CoordinatorImp: Coordinator {
        // MARK: - Coordinator

        func onStart() {
            
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
        fileprivate private(set) var notebook: Notebook
        fileprivate var model: Model

        fileprivate lazy var notebookViewController: NotebookViewController = {
            let vc = NotebookViewController()
            vc.navigationItem.largeTitleDisplayMode = .never
            vc.navigationItem.title = notebook.name
            vc.inject(dispatch: dispatch)
            return vc
        }()
        fileprivate let navigationController: NavigationController
        fileprivate var activeNote: Note?
        fileprivate var hidesBackButton = false

        init(withNavigationController navigationController: NavigationController, dependencies: Dependencies, notebook: Notebook) {
            self.navigationController = navigationController
            self.noteUseCase = dependencies.noteUseCase
            self.notebookUseCase = dependencies.notebookUseCase
            self.notebook = notebook
            // TODO: fixme
            model = Model()
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewControllerEvent) {
            handleEvaluation <| evaluateController(event: event, model: model)
        }

        fileprivate func handleEvaluation(result: EvaluatorResult) {
            model = result.model
            result.actions.forEach(perform)
            result.updates.forEach(notebookViewController.apply)
        }

        fileprivate func perform(action: Action) {
        }
    }
}

// MARK: - NoteViewControllerHandler

extension NotebookNamespace.CoordinatorImp: NoteViewControllerHandler {
    func didChangeContent(newContent: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = noteUseCase.update(activeNote, newContent: newContent)
            .recover(activeNote)
    }

    func didChangeTitle(newTitle: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = noteUseCase.update(activeNote, newTitle: newTitle)
            .recover(activeNote)
    }

    func onDeleteButtonClick() {
        guard let activeNote = activeNote else { return }
        guard noteUseCase.delete(activeNote).error == nil else { return }
        self.activeNote = nil
        navigationController.popViewController(animated: true)
    }

    func didAddTag(tag: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = noteUseCase.addTag(tag: tag, toNote: activeNote)
            .recover(activeNote)
    }

    func didRemoveTag(tag: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = noteUseCase.removeTag(tag: tag, fromNote: activeNote)
            .recover(activeNote)
    }

    func willDisappear() {
    }
}
