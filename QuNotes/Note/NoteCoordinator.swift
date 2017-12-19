//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result
import Core
import Prelude

extension Note {
    final class CoordinatorImp: Coordinator {
        // MARK: - Coordinator
        
        var viewController: UIViewController {
            return noteViewController
        }

        // MARK: - Life cycle

        fileprivate var fileExecuter: FileExecuter {
            return AppEnvironment.current.fileExecuter
        }
        fileprivate let navigationController: NavigationController
        fileprivate var evaluator: Evaluator
        fileprivate var noteEvaluator: Core.Note.Evaluator

        fileprivate lazy var noteViewController: NoteViewController = {
            return NoteViewController(withDispatch: dispatch)
        }()

        init(withNavigationController navigationController: NavigationController, note: Core.Note.Meta,
             isNewNote: Bool, notebook: Core.Notebook.Meta) {
            self.navigationController = navigationController
            evaluator = Evaluator(note: note, content: "", isNew: isNewNote)
            noteEvaluator = Core.Note.Evaluator(model: Core.Note.Model(meta: note, content: "", notebook: notebook))
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewEvent) {
            event |> evaluator.evaluate |> updateEvaluator
        }

        fileprivate func dispatch(event: CoordinatorEvent) {
            event |> evaluator.evaluate |> updateEvaluator
        }

        fileprivate func dispatchToNote(event: Core.Note.Event) {
            event |> noteEvaluator.evaluate |> updateNote
        }

        fileprivate func updateEvaluator(evaluator: Evaluator) {
            self.evaluator = evaluator
            evaluator.actions.forEach(perform)
            evaluator.effects.forEach(noteViewController.perform)
        }

        fileprivate func updateNote(note: Core.Note.Evaluator) {
            self.noteEvaluator = note
            note.effects.forEach(perform)
        }

        fileprivate func perform(action: Action) {
            switch action {
            case let .updateTitle(title):
                dispatchToNote <| .changeTitle(newTitle: title)
            case let .updateContent(content):
                dispatchToNote <| .changeContent(newContent: content)
            case let .addTag(tag):
                dispatchToNote <| .addTag(tag: tag)
            case let .removeTag(tag):
                dispatchToNote <| .removeTag(tag: tag)
            case .deleteNote:
                // TODO: who is responsible for that action?
                break
            case .finish:
                navigationController.popViewController(animated: true)
            case let .showError(title, message):
                showError(title: title, message: message)
            }
        }

        fileprivate func perform(effect: Core.Note.Effect) {
            switch effect {
            default:
                break
            }
        }
    }
}
