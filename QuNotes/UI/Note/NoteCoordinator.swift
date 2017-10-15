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
    enum Action {
        case updateTitle(title: String)
        case updateContent(content: String)
        case addTag(tag: String)
        case removeTag(tag: String)
        case delete
        case finish
    }

    enum CoordinatorEvent {
        case didUpdateTitle(note: Note)
        case didUpdateContent(note: Note)
        case didAddTag(note: Note, tag: String)
        case didRemoveTag(note: Note, tag: String)
        case didDeleteNote
        case didFailToUpdateTitle(error: AnyError)
        case didFailToUpdateContent(error: AnyError)
        case didFailToAddTag(error: AnyError)
        case didFailToRemoveTag(error: AnyError)
        case didFailToDeleteNote(error: AnyError)
    }

    struct Model {
        let note: Note
    }

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
        fileprivate var model: Model

        fileprivate lazy var noteViewController: NoteViewController = {
            let vc = NoteViewController()
            vc.inject(dispatch: dispatch)
            return vc
        }()
        fileprivate var activeNote: Note?

        init(withNavigationController navigationController: NavigationController, dependencies: Dependencies, note: Note) {
            self.navigationController = navigationController
            self.noteUseCase = dependencies.noteUseCase
            model = initialModel(withNote: note)
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewControllerEvent) {
            handleEvaluation <| evaluateController(event: event, model: model)
        }

        fileprivate func dispatch(event: CoordinatorEvent) {
            handleEvaluation <| evaluateCoordinator(event: event, model: model)
        }

        fileprivate func handleEvaluation(result: EvaluatorResult) {
            model = result.model
            result.actions.forEach(perform)
            result.updates.forEach(noteViewController.apply)
        }

        fileprivate func perform(action: Action) {
            switch action {
            case let .updateTitle(title):
                switch noteUseCase.update(model.note, newTitle: title) {
                case let .success(note):
                    dispatch(event: .didUpdateTitle(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToUpdateTitle(error: error))
                }
            case let .updateContent(content):
                switch noteUseCase.update(model.note, newContent: content) {
                case let .success(note):
                    dispatch(event: .didUpdateContent(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToUpdateContent(error: error))
                }
            case let .addTag(tag):
                switch noteUseCase.addTag(tag: tag, toNote: model.note) {
                case let .success(note):
                    dispatch(event: .didAddTag(note: note, tag: tag))
                case let .failure(error):
                    dispatch(event: .didFailToAddTag(error: error))
                }
            case let .removeTag(tag):
                switch noteUseCase.removeTag(tag: tag, fromNote: model.note) {
                case let .success(note):
                    dispatch(event: .didRemoveTag(note: note, tag: tag))
                case let .failure(error):
                    dispatch(event: .didFailToRemoveTag(error: error))
                }
            case .delete:
                switch noteUseCase.delete(model.note) {
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
