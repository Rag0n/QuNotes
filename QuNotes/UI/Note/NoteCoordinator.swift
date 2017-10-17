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
        case deleteNote
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

    enum ViewControllerEvent {
        case didLoad
        case changeContent(newContent: String)
        case changeTitle(newTitle: String)
        case delete
        case addTag(tag: String)
        case removeTag(tag: String)
    }

    enum ViewControllerUpdate {
        case updateTitle(title: String)
        case updateContent(content: String)
        case showTags(tags: [String])
        case addTag(tag: String)
        case removeTag(tag: String)
        case showError(error: String, message: String)
    }

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
            evaluator.updates.forEach(noteViewController.apply)
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

// MARK: - ViewControllerUpdate Equatable

extension UI.Note.ViewControllerUpdate: Equatable {}

func ==(lhs: UI.Note.ViewControllerUpdate, rhs: UI.Note.ViewControllerUpdate) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lTitle), .updateTitle(let rTitle)):
        return lTitle == rTitle
    case (.updateContent(let lContent), .updateContent(let rContent)):
        return lContent == rContent
    case (.showTags(let lTags), .showTags(let rTags)):
        return lTags == rTags
    case (.addTag(let lTag), .addTag(let rTag)):
        return lTag == rTag
    case (.removeTag(let lTag), .removeTag(let rTag)):
        return lTag == rTag
    case (.showError(let lError, let lMessage), .showError(let rError, let rMessage)):
        return (lError == rError) && (lMessage == rMessage)
    default: return false
    }
}

// MARK: - Action Equtable

extension UI.Note.Action: Equatable {}

func ==(lhs: UI.Note.Action, rhs: UI.Note.Action) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lTitle), .updateTitle(let rTitle)):
        return lTitle == rTitle
    case (.updateContent(let lContent), .updateContent(let rContent)):
        return lContent == rContent
    case (.addTag(let lTag), .addTag(let rTag)):
        return lTag == rTag
    case (.removeTag(let lTag), .removeTag(let rTag)):
        return lTag == rTag
    case (.deleteNote, .deleteNote):
        return true
    case (.finish, .finish):
        return true
    default: return false
    }
}
