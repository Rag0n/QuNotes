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
            coreEvaluator = Core.Note.Evaluator(model: model)
        }

        func onStart() {
            dispatchToCore <| .loadContent
        }

        var viewController: UIViewController {
            return noteViewController
        }

        private(set) var output: CoordinatorResultEffect = .none

        // MARK: - Private

        private func perform(action: Action) {
            switch action {
            case let .updateTitle(title):
                dispatchToCore <| .changeTitle(title)
            case let .updateCells(cells):
                dispatchToCore <| .changeCells(cells)
            case let .addTag(tag):
                dispatchToCore <| .addTag(tag)
            case let .removeTag(tag):
                dispatchToCore <| .removeTag(tag)
            case .deleteNote:
                output = .deleteNote(note)
                navigationController.popViewController(animated: true)
            case .finish:
                navigationController.popViewController(animated: true)
            case let .showFailure(failure, reason):
                showError(title: failure, message: reason)
            case let .didUpdateNote(note):
                output = .updateNote(note)
            }
        }

        private func perform(effect: Core.Note.Effect) {
            switch effect {
            case let .readContent(url):
                let result = fileExecuter.readFile(at: url, contentType: Core.Note.Content.self)
                dispatchToCore <| .didReadContent(result)
            case let .didLoadContent(content):
                dispatch <| .didLoadContent(content)
            case let .handleError(title, message):
                showError(title: title, message: message)
            case let .updateTitle(note, url, oldTitle):
                let error = fileExecuter.createFile(atURL: url, content: note)
                dispatchToCore <| .didChangeTitle(oldTitle: oldTitle, error: error)
                dispatch <| .didUpdateTitle(oldTitle: oldTitle, note: note, error: error)
            case let .updateContent(content, url, oldContent):
                let error = fileExecuter.createFile(atURL: url, content: content)
                dispatchToCore <| .didChangeContent(oldContent: oldContent, error: error)
                dispatch <| .didUpdateCells(oldCells: oldContent.cells, error: error)
            case let .addTag(tag, note, url):
                let error = fileExecuter.createFile(atURL: url, content: note)
                dispatchToCore <| .didAddTag(tag, error: error)
                dispatch <| .didAddTag(tag, note: note, error: error)
            case let .removeTag(tag, note, url):
                let error = fileExecuter.createFile(atURL: url, content: note)
                dispatchToCore <| .didRemoveTag(tag, error: error)
                dispatch <| .didRemoveTag(tag, note: note, error: error)
            }
        }

        // MARK: State

        private let navigationController: NavigationController
        private let note: Core.Note.Meta
        private lazy var noteViewController = NoteViewController(withDispatch: dispatch)
        private var fileExecuter: FileExecuterType {
            return AppEnvironment.current.fileExecuter
        }
        private var evaluator: Evaluator
        private var coreEvaluator: Core.Note.Evaluator

        // MARK: Utility

        private func dispatch(event: ViewEvent) {
            event |> evaluator.evaluating |> updateEvaluator
        }

        private func dispatch(event: CoordinatorEvent) {
            event |> evaluator.evaluating |> updateEvaluator
        }

        private func dispatchToCore(event: Core.Note.Event) {
            event |> coreEvaluator.evaluating |> updateCoreEvaluator
        }

        private func updateEvaluator(evaluator: Evaluator) {
            self.evaluator = evaluator
            evaluator.effects.forEach(noteViewController.perform)
            evaluator.actions.forEach(perform)
        }

        private func updateCoreEvaluator(coreEvaluator: Core.Note.Evaluator) {
            self.coreEvaluator = coreEvaluator
            coreEvaluator.effects.forEach(perform)
        }
    }
}
