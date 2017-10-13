//
// Created by Alexander Guschin on 13.10.2017.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation
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
    }

    enum NoteUseCaseEvent {
        case didUpdateNote(note: Note)
        case didDeleteNote(note: Note)
        case didFailToUpdateNote(note: Note)
        case didFailToDeleteNote(note: Note)
    }

    struct Model {
        let note: Note
    }

    class CoordinatorImp: Coordinator {
        // MARK: - Coordinator

        func onStart() {
            dispatch(event: .didUpdateNote(note: model.note))
        }

        var rootViewController: UIViewController {
            get {
                return notebookViewController
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
            self.notebookUseCase = dependencies.notebookUseCase
            model = initialModel(withNote: note)
        }

        // MARK: - Private

        fileprivate func dispatch(event: ViewControllerEvent) {
            handleEvaluation <| evaluateController(event: event, model: model)
        }

        fileprivate func dispatch(event: NoteUseCaseEvent) {
            handleEvaluation <| evaluateNoteUseCase(event: event, model: model)
        }

        fileprivate func handleEvaluation(result: EvaluatorResult) {
            model = result.model
            result.actions.forEach(perform)
            result.updates.forEach(notebookViewController.apply)
        }

        fileprivate func perform(action: Action) {
            switch action {
            case let .updateTitle(title):
                switch noteUseCase.update(model.note, newTitle: title) {
                case let .success(note):
                    dispatch(event: .didUpdateNote(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToUpdateNote(note: note))
                }
            case let .updateContent(content):
                switch noteUseCase.update(model.note, newContent: content) {
                case let .success(note):
                    dispatch(event: .didUpdateNote(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToUpdateNote(note: note))
                }
            case let .addTag(tag):
                switch noteUseCase.addTag(tag: tag, toNote: model.note) {
                case let .success(note):
                    dispatch(event: .didUpdateNote(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToUpdateNote(note: note))
                }
            case let .removeTag(tag):
                switch noteUseCase.removeTag(tag: tag, fromNote: model.note) {
                case let .success(note):
                    dispatch(event: .didUpdateNote(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToUpdateNote(note: note))
                }
            case .delete:
                switch noteUseCase.delete(model.note) {
                case let .success(note):
                    dispatch(event: .didDeleteNote(note: note))
                case let .failure(error):
                    dispatch(event: .didFailToDeleteNote(note: note))
                }
            }
        }
    }
}
