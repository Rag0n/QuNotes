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

        func onStart() {
        }

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
            let vc = NoteViewController()
            vc.inject(dispatch: dispatch)
            return vc
        }()
        fileprivate var activeNote: Note?

        init(withNavigationController navigationController: NavigationController, dependencies: Dependencies, note: Note) {
            self.navigationController = navigationController
            self.noteUseCase = dependencies.noteUseCase
            evaluator = Evaluator(withNote: note)
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
            evaluator.effects.forEach(noteViewController.apply)
        }

        fileprivate func perform(action: Action) {
            switch action {
            case let .updateTitle(title):
                switch noteUseCase.update(evaluator.model.note, newTitle: title) {
                case let .success(note):
                    dispatch(event: .didUpdateTitle(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToUpdateTitle(error: error))
                }
            case let .updateContent(content):
                switch noteUseCase.update(evaluator.model.note, newContent: content) {
                case let .success(note):
                    dispatch(event: .didUpdateContent(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToUpdateContent(error: error))
                }
            case let .addTag(tag):
                switch noteUseCase.addTag(tag: tag, toNote: evaluator.model.note) {
                case let .success(note):
                    dispatch(event: .didAddTag(note: note, tag: tag))
                case let .failure(error):
                    dispatch(event: .didFailToAddTag(error: error))
                }
            case let .removeTag(tag):
                switch noteUseCase.removeTag(tag: tag, fromNote: evaluator.model.note) {
                case let .success(note):
                    dispatch(event: .didRemoveTag(note: note, tag: tag))
                case let .failure(error):
                    dispatch(event: .didFailToRemoveTag(error: error))
                }
            case .deleteNote:
                switch noteUseCase.delete(evaluator.model.note) {
                case .success:
                    dispatch(event: .didDeleteNote)
                case let .failure(error):
                    dispatch(event: .didFailToDeleteNote(error: error))
                }
            case .finish:
                navigationController.popViewController(animated: true)
            }
        }
    }
}
