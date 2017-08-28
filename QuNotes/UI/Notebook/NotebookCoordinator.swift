//
//  NotebookCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class NotebookCoordinator: Coordinator {
    // MARK: - Coordinator

    func onStart() {
        updateNotebookViewModel()
    }

    var rootViewController: UIViewController {
        get {
            return notebookViewController
        }
    }

    // MARK: - Life cycle

    typealias Dependencies = HasNoteUseCase
    fileprivate let dependencies: Dependencies
    fileprivate lazy var notebookViewController: NotebookViewController = {
        let vc = NotebookViewController()
        vc.inject(handler: self)
        return vc
    }()
    fileprivate let navigationController: NavigationViewController
    fileprivate var activeNote: Note?

    init(withNavigationController navigationController: NavigationViewController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: - Private

    fileprivate func updateNotebookViewModel(withNoteTitleFilter titleFilter: String = "") {
        var notes = dependencies.noteUseCase.getAllNotes()
        if titleFilter.count > 0 {
            notes = notes.filter { $0.title.lowercased().contains(titleFilter) }
        }
        let notebookViewModel = NotebookViewModel(notes: notes.map { $0.title })
        notebookViewController.render(withViewModel: notebookViewModel)
    }
}

// MARK: - NotebookViewControllerHandler

extension NotebookCoordinator: NotebookViewControllerHandler {
    func didTapAddNote() {
        activeNote = dependencies.noteUseCase.addNote(withTitle: "")
        showNote(withActiveTitle: true)
    }

    func didTapOnNoteWithIndex(index: Int) {
        let notes = dependencies.noteUseCase.getAllNotes()
        guard (index < notes.count) else { return }
        activeNote = notes[index]
        showNote()
    }

    private func showNote(withActiveTitle isTitleActive: Bool = false) {
        guard let activeNote = activeNote else { return }
        let noteVC = NoteViewController()
        noteVC.navigationItem.largeTitleDisplayMode = .never
        noteVC.inject(handler: self)
        noteVC.render(withViewModel: NoteViewModel(title: activeNote.title, content: activeNote.content, isTitleActive: isTitleActive, tags: activeNote.tags))
        navigationController.pushViewController(viewController: noteVC, animated: true)
    }

    func didSwapeToDeleteNoteWithIndex(index: Int) {
        let notes = dependencies.noteUseCase.getAllNotes()
        guard (index < notes.count) else { return }
        dependencies.noteUseCase.deleteNote(notes[index])
        updateNotebookViewModel()
    }

    func didUpdateSearchResults(withText text: String?) {
        if let titleFilter = text?.lowercased() {
            updateNotebookViewModel(withNoteTitleFilter: titleFilter)
        } else {
            updateNotebookViewModel()
        }
    }
}

// MARK: - NoteViewControllerHandler

extension NotebookCoordinator: NoteViewControllerHandler {
    func didChangeContent(newContent: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = dependencies.noteUseCase.updateNote(activeNote, newContent: newContent)
            .recover(activeNote)
    }

    func didChangeTitle(newTitle: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = dependencies.noteUseCase.updateNote(activeNote, newTitle: newTitle)
            .recover(activeNote)
        updateNotebookViewModel()
    }

    func onDeleteButtonClick() {
        guard let activeNote = activeNote else { return }
        dependencies.noteUseCase.deleteNote(activeNote)
        updateNotebookViewModel()
        navigationController.popViewController(animated: true)
    }

    func didAddTag(tag: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = dependencies.noteUseCase.addTag(tag: tag, toNote: activeNote)
            .recover(activeNote)
    }

    func didRemoveTag(tag: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = dependencies.noteUseCase.removeTag(tag: tag, fromNote: activeNote)
            .recover(activeNote)
    }
}
