//
//  NotebookCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class NotebookCoordinator {
    typealias Dependencies = HasNoteUseCase

    let dependencies: Dependencies
    fileprivate var notebookViewController: NotebookViewController?
    fileprivate let navigationController: UINavigationController
    fileprivate var activeNote: Note?

    init(withNavigationController navigationController: UINavigationController, dependencies: Dependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        notebookViewController = NotebookViewController()
        notebookViewController!.inject(handler: self)
        updateNotebookViewModel()
        navigationController.pushViewController(notebookViewController!, animated: true)
    }

    fileprivate func updateNotebookViewModel(withNoteTitleFilter titleFilter: String = "") {
        var notes = dependencies.noteUseCase.getAllNotes()
        if titleFilter.count > 0 {
            notes = notes.filter { note in note.title.lowercased().contains(titleFilter) }
        }
        let notebookViewModel = NotebookViewModel(notes: notes.map { note in note.title })
        notebookViewController?.render(withViewModel: notebookViewModel)
    }
}

extension NotebookCoordinator: NotebookViewControllerHandler {
    func didTapAddNote() {
        activeNote = dependencies.noteUseCase.addNote(withTitle: "")
        showNote()
    }

    func didTapOnNoteWithIndex(index: Int) {
        let notes = dependencies.noteUseCase.getAllNotes()
        guard (index < notes.count) else { return }
        activeNote = notes[index]
        showNote()
    }

    private func showNote() {
        guard let activeNote = activeNote else { return }
        let noteVC = NoteViewController()
        if #available(iOS 11.0, *) {
            noteVC.navigationItem.largeTitleDisplayMode = .never
        }
        noteVC.inject(handler: self)
        noteVC.render(withViewModel: NoteViewModel(title: activeNote.title, content: activeNote.content))
        navigationController.pushViewController(noteVC, animated: true)
    }

    func didSwapeToDeleteNoteWithIndex(index: Int) {
        let notes = dependencies.noteUseCase.getAllNotes()
        guard (index < notes.count) else { return }
        dependencies.noteUseCase.deleteNote(notes[index])
    }

    func didUpdateSearchResults(withText text: String?) {
        if let titleFilter = text?.lowercased() {
            updateNotebookViewModel(withNoteTitleFilter: titleFilter)
        } else {
            updateNotebookViewModel()
        }
    }
}

extension NotebookCoordinator: NoteViewControllerHandler {
    func didChangeContent(newContent: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = dependencies.noteUseCase.updateNote(activeNote, newContent: newContent)
    }

    func didChangeTitle(newTitle: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = dependencies.noteUseCase.updateNote(activeNote, newTitle: newTitle)
    }

    func onBackButtonClick() {
        updateNotebookViewModel()
        self.navigationController.popViewController(animated: true)
    }
}
