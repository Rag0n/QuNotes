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

    fileprivate func updateNotebookViewModel() {
        let notes = dependencies.noteUseCase.getAllNotes()
        let notebookViewModel = NotebookViewModel(notes: notes.map { note in note.content })
        notebookViewController?.render(withViewModel: notebookViewModel)
    }
}

extension NotebookCoordinator: NotebookViewControllerHandler {
    func didTapAddNote() {
        dependencies.noteUseCase.addNote(withContent: "note fixture")
        updateNotebookViewModel()
    }

    func didTapOnNoteWithIndex(index: Int) {
        let notes = dependencies.noteUseCase.getAllNotes()
        guard (index < notes.count) else { return }
        activeNote = notes[index]
        showNote()
    }

    private func showNote() {
        let noteVC = NoteViewController()
        noteVC.inject(handler: self)
        noteVC.render(withViewModel: NoteViewModel(content: activeNote!.content))
        navigationController.pushViewController(noteVC, animated: true)
    }
}

extension NotebookCoordinator: NoteViewControllerHandler {
    func didChangeContent(newContent: String) {
        if let activeNote = activeNote {
            self.activeNote = dependencies.noteUseCase.updateNote(activeNote, newContent: newContent)
        }
    }

    func onBackButtonClick() {
        updateNotebookViewModel()
        self.navigationController.popViewController(animated: true)
    }
}
