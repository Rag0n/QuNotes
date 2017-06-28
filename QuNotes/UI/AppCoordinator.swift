//
// Created by Alexander Guschin on 27.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class AppCoordinator {

    private let window: UIWindow
    fileprivate let noteUseCase: NoteUseCase
    fileprivate var notebookViewController: NotebookViewController?
    fileprivate var navigationController: UINavigationController!

    init(withWindow window: UIWindow) {
        self.window = window
        noteUseCase = NoteUseCase()
    }

    func start() {
        notebookViewController = NotebookViewController()
        notebookViewController!.inject(handler: self)
        updateNotebookViewModel()
        navigationController = UINavigationController(rootViewController: notebookViewController!)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    fileprivate func updateNotebookViewModel() {
        let notes = noteUseCase.getAllNotes()
        let notebookViewModel = NotebookViewModel(notes: notes.map { note in note.content })
        notebookViewController?.render(withViewModel: notebookViewModel)
    }
}

extension AppCoordinator: NotebookViewControllerHandler {
    func didTapAddNote() {
        noteUseCase.addNote(withContent: "note fixture")
        updateNotebookViewModel()
    }
}
