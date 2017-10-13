//
//  NotebookCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result

enum UI {}
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

    enum NoteUseCaseEvent {
        case didUpdateNotes(notes: [Note])
        case didAddNote(note: Note)
        case didDeleteNote(note: Note)
        case didUpdateNotebook(notebook: Notebook)
        case didDeleteNotebook(notebook: Notebook)
        case didFailToAddNote(error: AnyError)
        case didFailToDeleteNote(error: AnyError)
        case didFailToUpdateNotebook(error: AnyError)
        case didFailToDeleteNotebook(error: AnyError)
    }

    struct Model {
        let notebook: Notebook
        let notes: [Note]
    }

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
            model = initialModel(withNotebook: notebook)
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewControllerEvent) {
            handleEvaluation <| evaluateController(event: event, model: model)
        }

        fileprivate func dispatch(event: NoteUseCaseEvent) {
            handleEvaluation <| evaluateNoteUseCase(event: event, model: model)
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
                let noteVC = NoteViewController()
                noteVC.navigationItem.largeTitleDisplayMode = .never
                noteVC.inject(handler: self)
                noteVC.render(withViewModel: NoteViewModel(title: note.title, content: note.content, isTitleActive: true, tags: note.tags))
                navigationController.pushViewController(viewController: noteVC, animated: true)
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
                case let .success(notebook):
                    dispatch(event: .didDeleteNotebook(notebook: notebook))
                case let .failure(error):
                    dispatch(event: .didFailToDeleteNotebook(error: error))
                }
            case .finish:
                navigationController.popViewController(animated: true)
            }
        }
    }
}

// MARK: - NoteViewControllerHandler

extension UI.Notebook.CoordinatorImp: NoteViewControllerHandler {
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
