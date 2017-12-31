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
            evaluator = Evaluator(note: note, content: "", isNew: isNewNote)
            noteEvaluator = Core.Note.Evaluator(model: Core.Note.Model(meta: note, content: "", notebook: notebook))
        }

        var viewController: UIViewController {
            return noteViewController
        }

        var output = 0
        // MARK: - Private

        private func perform(action: Action) {
            switch action {
            case let .updateTitle(title):
                dispatchToNote <| .changeTitle(title)
            case let .updateContent(content):
                dispatchToNote <| .changeContent(content)
            case let .addTag(tag):
                dispatchToNote <| .addTag(tag)
            case let .removeTag(tag):
                dispatchToNote <| .removeTag(tag)
            case .deleteNote:
                // TODO: who is responsible for that action?
                break
            case .finish:
                navigationController.popViewController(animated: true)
            case let .showError(title, message):
                showError(title: title, message: message)
            }
        }

        private func perform(effect: Core.Note.Effect) {
            switch effect {
            case let .updateTitle(note, url, oldTitle):
                let error = fileExecuter.createFile(atURL: url, content: note)
                dispatchToNote <| .didChangeTitle(oldTitle: oldTitle, error: error)
                dispatch <| .didUpdateTitle(oldTitle: oldTitle, error: error)
            case let .updateContent(content, url, oldContent):
                let error = fileExecuter.createFile(atURL: url, content: content)
                dispatchToNote <| .didChangeContent(oldContent: oldContent, error: error)
                dispatch <| .didUpdateContent(oldContent: oldContent, error: error)
            case let .addTag(tag, note, url):
                let error = fileExecuter.createFile(atURL: url, content: note)
                dispatchToNote <| .didAddTag(tag, error: error)
                dispatch <| .didAddTag(tag, error: error)
            case let .removeTag(tag, note, url):
                let error = fileExecuter.createFile(atURL: url, content: note)
                dispatchToNote <| .didRemoveTag(tag, error: error)
                dispatch <| .didRemoveTag(tag, error: error)
            }
        }

        // MARK: State
        private let navigationController: NavigationController
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
