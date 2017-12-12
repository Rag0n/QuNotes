//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result

extension UI.Note {
    typealias ViewDispacher = (_ event: ViewEvent) -> ()

    class CoordinatorImp: Coordinator {
        // MARK: - Coordinator
        
        var viewController: UIViewController {
            return noteViewController
        }

        // MARK: - Life cycle

        typealias Dependencies = HasFileExecuter
        fileprivate let navigationController: NavigationController
        fileprivate var evaluator: Evaluator

        fileprivate lazy var noteViewController: NoteViewController = {
            return NoteViewController(withDispatch: dispatch)
        }()

        init(withNavigationController navigationController: NavigationController,
             dependencies: Dependencies, note: Note.Meta, isNewNote: Bool) {
            self.navigationController = navigationController
            evaluator = Evaluator(note: note, content: "", isNew: isNewNote)
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewEvent) {
            updateEvaluator <| evaluator.evaluate(event: event)
        }

        fileprivate func dispatch(event: CoordinatorEvent) {
            updateEvaluator <| evaluator.evaluate(event: event)
        }

        fileprivate func updateEvaluator(evaluator: Evaluator) {
            self.evaluator = evaluator
            evaluator.actions.forEach(perform)
            evaluator.effects.forEach(noteViewController.perform)
        }

        fileprivate func perform(action: Action) {
            switch action {
            case let .updateTitle(title):
                break
            case let .updateContent(content):
                break
            case let .addTag(tag):
                break
            case let .removeTag(tag):
                break
            case .deleteNote:
                break
            case .finish:
                navigationController.popViewController(animated: true)
            case let .showError(title, message):
                showError(title: title, message: message)
            }
        }
    }
}
