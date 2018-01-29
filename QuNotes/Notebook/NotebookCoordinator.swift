//
//  NotebookCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Core
import Prelude

extension Notebook {
    final class CoordinatorImp: Coordinator {
        init(withNavigationController navigationController: NavigationController, notebook: Core.Notebook.Meta) {
            self.navigationController = navigationController
            self.evaluator = Evaluator(notebook: notebook)
            self.notebookEvaluator = Core.Notebook.Evaluator(model: Core.Notebook.Model(meta: notebook, notes: []))
            self.notebook = notebook
        }

        func onStart() {
            .loadNotes |> dispatchToNotebook
        }

        var viewController: UIViewController {
            return notebookViewController
        }

        private(set) var output: CoordinatorResultEffect = .none

        // MARK: - Private

        private func perform(action: Action) {
            switch action {
            case let .addNote(note):
                dispatchToNotebook <| .addNote(note)
            case let .deleteNote(note):
                dispatchToNotebook <| .removeNote(note)
            case let .updateNotebook(title):
                dispatchToNotebook <| .changeName(title)
            case .deleteNotebook:
                output = .deleteNotebook(notebook)
                navigationController.popViewController(animated: true)
            case .finish:
                navigationController.popViewController(animated: true)
            case let .showFailure(failure, reason):
                showError(title: failure, message: reason)
            case let .showNote(note, isNewNote):
                let noteCoordinator = Note.CoordinatorImp(withNavigationController: navigationController,
                                                          note: note, isNewNote: isNewNote, notebook: notebook)
                navigationController.pushCoordinator(coordinator: noteCoordinator, animated: true) { [unowned self] in
                    self.handleNoteCoordinatorOutput(output: noteCoordinator.output)
                }
            case let .didUpdateNotebook(notebook):
                output = .updateNotebook(notebook)
            }
        }

        private func perform(action: Core.Notebook.Effect) {
            switch action {
            case let .createNote(note, url, content, contentURL):
                let metaError = fileExecuter.createFile(atURL: url, content: note)
                let contentError = fileExecuter.createFile(atURL: contentURL, content: content)
                dispatchToNotebook <| .didAddNote(note, error: metaError ?? contentError)
                dispatch <| .didAddNote(note, error:  metaError ?? contentError)
            case let .updateNotebook(notebook, url, oldNotebook):
                let error = fileExecuter.createFile(atURL: url, content: notebook)
                dispatchToNotebook <| .didUpdateNotebook(oldNotebook: oldNotebook, error: error)
                dispatch <| .didUpdateNotebook(oldNotebook: oldNotebook, error: error)
            case let .deleteNote(note, url):
                let error = fileExecuter.deleteFile(at: url)
                dispatchToNotebook <| .didDeleteNote(note, error: error)
                dispatch <| .didDeleteNote(note, error: error)
            case let .readDirectory(url):
                let urls = fileExecuter.contentOfFolder(at: url)
                dispatchToNotebook <| .didReadDirectory(urls: urls)
            case let .readNotes(urls):
                let notes = urls.map { fileExecuter.readFile(at: $0, contentType: Core.Note.Meta.self) }
                dispatchToNotebook <| .didReadNotes(notes)
            case let .handleError(title, message):
                showError(title: title, message: message)
            case let .didLoadNotes(notes):
                dispatch <| .didLoadNotes(notes)
            case let .removeDirectory(url):
                _ = fileExecuter.deleteDirectory(at: url)
            }
        }

        private func handleNoteCoordinatorOutput(output: Note.CoordinatorImp.ResultEffect) {
            switch (output) {
            case let .updateNote(note):
                dispatch <| .updateNote(note)
            case let .deleteNote(note):
                dispatch <| .deleteNote(note)
            case .none:
                break
            }
        }

        // MARK: State

        private let navigationController: NavigationController
        private var evaluator: Evaluator
        private var notebookEvaluator: Core.Notebook.Evaluator
        private let notebook: Core.Notebook.Meta
        private lazy var notebookViewController: NotebookViewController = {
            let vc = NotebookViewController(withDispatch: dispatch)
            vc.navigationItem.largeTitleDisplayMode = .never
            return vc
        }()
        private var fileExecuter: FileExecuterType {
            return AppEnvironment.current.fileExecuter
        }

        // MARK: Utility

        private func dispatch(event: ViewEvent) {
            event |> evaluator.evaluating |> updateEvaluator
        }

        private func dispatch(event: CoordinatorEvent) {
            event |> evaluator.evaluating |> updateEvaluator
        }

        private func dispatchToNotebook(event: Core.Notebook.Event) {
            event |> notebookEvaluator.evaluating |> updateNotebook
        }

        private func updateEvaluator(evaluator: Evaluator) {
            self.evaluator = evaluator
            evaluator.effects.forEach(notebookViewController.perform)
            evaluator.actions.forEach(perform)
        }

        private func updateNotebook(notebook: Core.Notebook.Evaluator) {
            self.notebookEvaluator = notebook
            notebook.effects.forEach(perform)
        }
    }
}
