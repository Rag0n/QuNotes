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
            .loadNotes |> dispatchToNotebook
        }

        var rootViewController: UIViewController {
            get {
                return notebookViewController
            }
        }

        // MARK: - Life cycle

        typealias Dependencies = HasFileExecuter
        fileprivate let dependencies: Dependencies
        fileprivate let fileExecuter: FileExecuter
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
            self.fileExecuter = dependencies.fileExecuter
            self.evaluator = Evaluator(notebook: notebook)
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
            switch action {
            case .addNote:
//                dispatch <| .addNote(note: note)
//                let result = noteUseCase.add(withTitle: "")
//                dispatch <| .didAddNote(result: result)
                break;
            case .deleteNote(let note):
//                let result = noteUseCase.delete(note)
//                dispatch <| .didDeleteNote(result: result)
                break
            case .updateNotebook(let notebook, let title):
//                let result = notebookUseCase.update(notebook, name: title)
//                dispatch <| .didUpdateNotebook(result: result)
                break
            case .deleteNotebook(let notebook):
//                let result = notebookUseCase.delete(notebook)
//                dispatch <| .didDeleteNotebook(error: result.error)
                break
            case .finish:
//                navigationController.popViewController(animated: true)
                break
            case let .showError(title, message):
                showError(title: title, message: message, controller: notebookViewController)
            case let .showNote(note, isNewNote):
//                let noteCoordinator = UI.Note.CoordinatorImp(withNavigationController: navigationController,
//                                                             dependencies: dependencies,
//                                                             note: note,
//                                                             isNewNote: isNewNote)
//                navigationController.pushCoordinator(coordinator: noteCoordinator,
//                                                     animated: true) { [unowned self] in
//                                                        self.onStart()
//                }
                break
            }
        }

        fileprivate func perform(action: Notebook.Action) {
            switch action {
            case let .readDirectory(url):
                let urls = fileExecuter.contentOfFolder(at: url)
                 dispatchToNotebook <| .didReadDirectory(urls: urls)
            case let .readNotes(urls):
                let result = urls.map { fileExecuter.readFile(at: $0, contentType: Note.Meta.self) }
                dispatchToNotebook <| .didReadNotes(notes: result)
            case let .handleError(title, message):
                showError(title: title, message: message, controller: notebookViewController)
            case let .didLoadNotes(notes):
                dispatch <| .didLoadNotes(notes: notes)
            default:
                return
            }
        }
    }

    typealias ViewControllerDispacher = (_ event: UI.Notebook.ViewControllerEvent) -> ()
}
