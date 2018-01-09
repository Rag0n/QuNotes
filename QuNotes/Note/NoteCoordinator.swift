//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Core
import Prelude

extension Note {
    final class CoordinatorImp: Coordinator {
        init(withNavigationController navigationController: NavigationController, note: Core.Note.Meta,
             isNewNote: Bool, notebook: Core.Notebook.Meta) {
            self.navigationController = navigationController
            self.note = note
            evaluator = Evaluator(note: note, cells: [], isNew: isNewNote)
            let content = Core.Note.Content(title: note.title, cells: [])
            let model = Core.Note.Model(meta: note, content: content, notebook: notebook)
            noteEvaluator = Core.Note.Evaluator(model: model)
        }

        func onStart() {
            dispatchToNote <| .loadContent
        }

        var viewController: UIViewController {
            return noteViewController
        }

        private(set) var output: CoordinatorResultEffect = .none

        // MARK: - Private

        private func perform(action: Action) {
            switch action {
            case let .updateTitle(title):
                dispatchToNote <| .changeTitle(title)
            case let .updateCells(cells):
                dispatchToNote <| .changeCells(cells)
            case let .addTag(tag):
                dispatchToNote <| .addTag(tag)
            case let .removeTag(tag):
                dispatchToNote <| .removeTag(tag)
            case .deleteNote:
                output = .deleteNote(note)
                navigationController.popViewController(animated: true)
            case .finish:
                navigationController.popViewController(animated: true)
            case let .showError(title, message):
                showError(title: title, message: message)
            }
        }

        private func perform(effect: Core.Note.Effect) {
            switch effect {
            case let .readContent(url):
                let result = fileExecuter.readFile(at: url.appendedToDocumentsURL(), contentType: Core.Note.Content.self)
                dispatchToNote <| .didReadContent(result)
            case let .didLoadContent(content):
                dispatch <| .didLoadContent(content)
            case let .handleError(title, message):
                // TODO: When UI is not loaded error will not be shown
                showError(title: title, message: message)
            case let .updateTitle(note, url, oldTitle):
                output = .updateNote(note)
                let error = fileExecuter.createFile(atURL: url, content: note)
                dispatchToNote <| .didChangeTitle(oldTitle: oldTitle, error: error)
                dispatch <| .didUpdateTitle(oldTitle: oldTitle, error: error)
            case let .updateContent(content, url, oldContent):
                let error = fileExecuter.createFile(atURL: url, content: content)
                dispatchToNote <| .didChangeContent(oldContent: oldContent, error: error)
                dispatch <| .didUpdateCells(oldCells: oldContent.cells, error: error)
            case let .addTag(tag, note, url):
                output = .updateNote(note)
                let error = fileExecuter.createFile(atURL: url, content: note)
                dispatchToNote <| .didAddTag(tag, error: error)
                dispatch <| .didAddTag(tag, error: error)
            case let .removeTag(tag, note, url):
                output = .updateNote(note)
                let error = fileExecuter.createFile(atURL: url, content: note)
                dispatchToNote <| .didRemoveTag(tag, error: error)
                dispatch <| .didRemoveTag(tag, error: error)
            }
        }

        // MARK: State
        private let navigationController: NavigationController
        private let note: Core.Note.Meta
        private var evaluator: Evaluator
        private var noteEvaluator: Core.Note.Evaluator
        private lazy var noteViewController: NoteViewController = {
            return NoteViewController(withDispatch: dispatch)
        }()
        private var fileExecuter: FileExecuterType {
            return AppEnvironment.current.fileExecuter
        }

        // MARK: Utility

        private func dispatch(event: ViewEvent) {
            event |> evaluator.evaluate |> updateEvaluator
        }

        private func dispatch(event: CoordinatorEvent) {
            event |> evaluator.evaluate |> updateEvaluator
        }

        private func dispatchToNote(event: Core.Note.Event) {
            event |> noteEvaluator.evaluate |> updateNote
        }

        private func updateEvaluator(evaluator: Evaluator) {
            self.evaluator = evaluator
            evaluator.actions.forEach(perform)
            evaluator.effects.forEach(noteViewController.perform)
        }

        private func updateNote(note: Core.Note.Evaluator) {
            self.noteEvaluator = note
            note.effects.forEach(perform)
        }
    }
}
