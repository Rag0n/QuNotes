//
//  NotebookCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class NotebookCoordinator {
    fileprivate let noteUseCase: NoteUseCase
    fileprivate var notebookViewController: NotebookViewController?
    fileprivate let navigationController: UINavigationController

    init(withNavigationController navigationController: UINavigationController) {
        self.navigationController = navigationController
        noteUseCase = NoteUseCase()
    }

    func start() {
        notebookViewController = NotebookViewController()
        notebookViewController!.inject(handler: self)
        updateNotebookViewModel()
        navigationController.pushViewController(notebookViewController!, animated: true)
    }

    fileprivate func updateNotebookViewModel() {
        let notes = noteUseCase.getAllNotes()
        let notebookViewModel = NotebookViewModel(notes: notes.map { note in note.content })
        notebookViewController?.render(withViewModel: notebookViewModel)
    }
}

extension NotebookCoordinator: NotebookViewControllerHandler {
    func didTapAddNote() {
        noteUseCase.addNote(withContent: "note fixture")
        updateNotebookViewModel()
    }
}