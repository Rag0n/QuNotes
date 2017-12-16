//
//  NotebookCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result
import Core

extension Notebook {
    final class CoordinatorImp: Coordinator {
        // MARK: - Coordinator

        func onStart() {
            .loadNotes |> dispatchToNotebook
        }

        var viewController: UIViewController {
            return notebookViewController
        }

        // MARK: - Life cycle

        typealias Dependencies = HasFileExecuter
        fileprivate let dependencies: Dependencies
        fileprivate let fileExecuter: FileExecuter
        fileprivate let navigationController: NavigationController
        fileprivate var evaluator: Evaluator
        fileprivate var notebookEvaluator: Core.Notebook.Evaluator
        fileprivate let notebook: Core.Notebook.Meta

        fileprivate lazy var notebookViewController: NotebookViewController = {
            let vc = NotebookViewController(withDispatch: dispatch)
            vc.navigationItem.largeTitleDisplayMode = .never
            return vc
        }()

        init(withNavigationController navigationController: NavigationController, dependencies: Dependencies, notebook: Core.Notebook.Meta) {
            self.navigationController = navigationController
            self.dependencies = dependencies
            self.fileExecuter = dependencies.fileExecuter
            self.evaluator = Evaluator(notebook: notebook)
            self.notebookEvaluator = Core.Notebook.Evaluator(model: Core.Notebook.Model(meta: notebook, notes: []))
            self.notebook = notebook
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewEvent) {
            event |> evaluator.evaluate |> updateEvaluator
        }

        fileprivate func dispatch(event: CoordinatorEvent) {
            event |> evaluator.evaluate |> updateEvaluator
        }

        fileprivate func dispatchToNotebook(event: Core.Notebook.Event) {
            event |> notebookEvaluator.evaluate |> updateNotebook
        }

        fileprivate func updateEvaluator(evaluator: Evaluator) {
            self.evaluator = evaluator
            evaluator.actions.forEach(perform)
            evaluator.effects.forEach(notebookViewController.perform)
        }

        fileprivate func updateNotebook(notebook: Core.Notebook.Evaluator) {
            self.notebookEvaluator = notebook
            notebook.effects.forEach(perform)
        }

        fileprivate func perform(action: Action) {
            switch action {
            case let .addNote(note):
                dispatchToNotebook <| .addNote(note: note)
            case let .deleteNote(note):
                dispatchToNotebook <| .removeNote(note: note)
            case let .updateNotebook(notebook, title):
                dispatchToNotebook <| .changeName(newName: title)
            case let .deleteNotebook(notebook):
                // TODO: Interesting case. Should use library evaluator? Or not..
                break
            case .finish:
                navigationController.popViewController(animated: true)
            case let .showError(title, message):
                showError(title: title, message: message)
            case let .showNote(note, isNewNote):
                let noteCoordinator = Note.CoordinatorImp(withNavigationController: navigationController,
                                                             dependencies: dependencies, note: note,
                                                             isNewNote: isNewNote, notebook: notebook)
                navigationController.pushCoordinator(coordinator: noteCoordinator, animated: true)
            }
        }

        fileprivate func perform(action: Core.Notebook.Effect) {
            switch action {
            case let .createNote(note, url):
                let error = fileExecuter.createFile(atURL: url, content: note)
                dispatchToNotebook <| .didAddNote(note: note, error: error)
                dispatch <| .didAddNote(note: note, error: error)
            case let .updateNotebook(notebook, url):
                let error = fileExecuter.createFile(atURL: url, content: notebook)
                dispatchToNotebook <| .didUpdateNotebook(notebook: notebook, error: error)
                dispatch <| .didUpdateNotebook(notebook: notebook, error: error)
            case let .deleteNote(note, url):
                let error = fileExecuter.deleteFile(at: url)
                dispatchToNotebook <| .didDeleteNote(note: note, error: error)
                dispatch <| .didDeleteNote(note: note, error: error)
            case let .readDirectory(url):
                let urls = fileExecuter.contentOfFolder(at: url)
                 dispatchToNotebook <| .didReadDirectory(urls: urls)
            case let .readNotes(urls):
                let result = urls.map { fileExecuter.readFile(at: $0, contentType: Core.Note.Meta.self) }
                dispatchToNotebook <| .didReadNotes(notes: result)
            case let .handleError(title, message):
                // TODO: When UI is not loaded error will not be shown
                showError(title: title, message: message)
            case let .didLoadNotes(notes):
                dispatch <| .didLoadNotes(notes: notes)
            }
        }
    }
}
