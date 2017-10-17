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
    enum Action {
        case addNote
        case showNote(note: Note)
        case deleteNote(note: Note)
        case deleteNotebook(notebook: Notebook)
        case updateNotebook(notebook: Notebook, title: String)
        case finish
    }

    enum CoordinatorEvent {
        case didUpdateNotes(notes: [Note])
        case didAddNote(note: Note)
        case didDeleteNote(note: Note)
        case didUpdateNotebook(notebook: Notebook)
        case didDeleteNotebook
        case didFailToAddNote(error: AnyError)
        case didFailToDeleteNote(error: AnyError)
        case didFailToUpdateNotebook(error: AnyError)
        case didFailToDeleteNotebook(error: AnyError)
    }

    struct Model {
        let notebook: Notebook
        let notes: [Note]
    }

    enum ViewControllerEvent {
        case addNote
        case selectNote(index: Int)
        case deleteNote(index: Int)
        case deleteNotebook
        case filterNotes(filter: String?)
        case didStartToEditTitle
        case didFinishToEditTitle(newTitle: String?)
    }

    enum ViewControllerUpdate {
        case updateAllNotes(notes: [String])
        case hideBackButton
        case showBackButton
        case updateTitle(title: String)
        case deleteNote(index: Int, notes: [String])
        case showError(error: String, message: String)
    }

    typealias ViewControllerDispacher = (_ event: UI.Notebook.ViewControllerEvent) -> ()

    class CoordinatorImp: Coordinator {
        // MARK: - Coordinator

        func onStart() {
            let notes = noteUseCase.getAll()
            dispatch(event: .didUpdateNotes(notes: notes))
            dispatch(event: .didUpdateNotebook(notebook: model.notebook))
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
        fileprivate var model: Model

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
            model = initialModel(withNotebook: notebook)
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewControllerEvent) {
            handleEvaluation <| evaluateController(event: event, model: model)
        }

        fileprivate func dispatch(event: CoordinatorEvent) {
            handleEvaluation <| evaluateCoordinator(event: event, model: model)
        }

        fileprivate func handleEvaluation(result: EvaluatorResult) {
            model = result.model
            result.actions.forEach(perform)
            result.updates.forEach(notebookViewController.apply)
        }

        fileprivate func perform(action: Action) {
            switch action {
            case .addNote:
                switch noteUseCase.add(withTitle: "") {
                case let .success(note):
                    dispatch(event: .didAddNote(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToAddNote(error: error))
                }
            case .showNote(let note):
                let noteCoordinator = UI.Note.CoordinatorImp(withNavigationController: navigationController,
                                                             dependencies: dependencies,
                                                             note: note)
                navigationController.pushCoordinator(coordinator: noteCoordinator, animated: true) { [unowned self] in
                    self.onStart()
                }
            case .deleteNote(let note):
                switch noteUseCase.delete(note) {
                case let .success(note):
                    dispatch(event: .didDeleteNote(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToDeleteNote(error: error))
                }
                return
            case .updateNotebook(let notebook, let title):
                switch notebookUseCase.update(notebook, name: title) {
                case let .success(notebook):
                    dispatch(event: .didUpdateNotebook(notebook: notebook))
                case let .failure(error):
                    dispatch(event: .didFailToUpdateNotebook(error: error))
                }
            case .deleteNotebook(let notebook):
                switch notebookUseCase.delete(notebook) {
                case .success:
                    dispatch(event: .didDeleteNotebook)
                case let .failure(error):
                    dispatch(event: .didFailToDeleteNotebook(error: error))
                }
            case .finish:
                navigationController.popViewController(animated: true)
            }
        }
    }
}
