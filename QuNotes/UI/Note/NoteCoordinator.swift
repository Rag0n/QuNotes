//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Result

extension UI {
    enum Note {}
}

extension UI.Note {
    typealias ViewControllerDispacher = (_ event: ViewControllerEvent) -> ()

    class CoordinatorImp: Coordinator {
        // MARK: - Coordinator
        
        var rootViewController: UIViewController {
            get {
                return noteViewController
            }
        }

        // MARK: - Life cycle

        typealias Dependencies = HasNoteUseCase
        fileprivate let noteUseCase: NoteUseCase
        fileprivate let navigationController: NavigationController
        fileprivate var evaluator: Evaluator

        fileprivate lazy var noteViewController: NoteViewController = {
            return NoteViewController(withDispatch: dispatch)
        }()
        fileprivate var activeNote: Note?

        init(withNavigationController navigationController: NavigationController,
             dependencies: Dependencies,
             note: Note,
             isNewNote: Bool) {
            self.navigationController = navigationController
            self.noteUseCase = dependencies.noteUseCase
            evaluator = Evaluator(withNote: note, isNew: isNewNote)
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewControllerEvent) {
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
                let result = noteUseCase.update(evaluator.model.note, newTitle: title)
                dispatch <| .didUpdateTitle(result: result)
            case let .updateContent(content):
                let result = noteUseCase.update(evaluator.model.note, newContent: content)
                dispatch <| .didUpdateContent(result: result)
            case let .addTag(tag):
                let result = noteUseCase.addTag(tag: tag, toNote: evaluator.model.note)
                dispatch <| .didAddTag(result: result, tag: tag)
            case let .removeTag(tag):
                let result = noteUseCase.removeTag(tag: tag, fromNote: evaluator.model.note)
                dispatch <| .didRemoveTag(result: result, tag: tag)
            case .deleteNote:
                let result = noteUseCase.delete(evaluator.model.note)
                dispatch <| .didDeleteNote(error: result.error)
            case .finish:
                navigationController.popViewController(animated: true)
            case let .showError(title, message):
                showError(title: title, message: message, controller: noteViewController)
            }
        }
    }
}
