//
//  NotebookCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
enum NotebookNamespace {}

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

    typealias Dependencies = HasNoteUseCase & HasNotebookUseCase
    fileprivate let noteUseCase: NoteUseCase
    fileprivate let notebookUseCase: NotebookUseCase
    fileprivate private(set) var notebook: Notebook
    fileprivate lazy var notebookViewController: NotebookViewController = {
        let vc = NotebookViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.navigationItem.title = notebook.name
        vc.inject(handler: self)
        return vc
    }()
    fileprivate let navigationController: NavigationController
    fileprivate var activeNote: Note?
    fileprivate var hidesBackButton = false

    init(withNavigationController navigationController: NavigationController, dependencies: Dependencies, notebook: Notebook) {
        self.navigationController = navigationController
        self.noteUseCase = dependencies.noteUseCase
        self.notebookUseCase = dependencies.notebookUseCase
        self.notebook = notebook
    }

    // MARK: - Private

    fileprivate func updateNotebookViewModel(withNoteTitleFilter titleFilter: String = "") {
        var notes = noteUseCase.getAll()
        if titleFilter.count > 0 {
            notes = notes.filter { $0.title.lowercased().contains(titleFilter) }
        }
        let notebookViewModel = NotebookViewModel(title: notebook.name,
                                                  hidesBackButton: hidesBackButton,
                                                  notes: notes.map { $0.title })
        notebookViewController.render(withViewModel: notebookViewModel)
    }
}

// MARK: - NotebookViewControllerHandler

extension NotebookCoordinator: NotebookViewControllerHandler {
    func didTapAddNote() {
        let addingResult = noteUseCase.add(withTitle: "")
        switch (addingResult) {
            case let .success(note):
                activeNote = note
                showNote(withActiveTitle: true)
            case .failure(_):
                // TODO: show alert with error message or smth like that
                return
        }

    }

    func didTapOnNoteWithIndex(index: Int) {
        let notes = noteUseCase.getAll()
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

    func didSwapeToDeleteNoteWithIndex(index: Int) -> Bool {
        let notes = noteUseCase.getAll()
        guard (index < notes.count) else { return false }
        guard noteUseCase.delete(notes[index]).error == nil else { return false }
        updateNotebookViewModel()
        return true;
    }

    func didUpdateSearchResults(withText text: String?) {
        if let titleFilter = text?.lowercased() {
            updateNotebookViewModel(withNoteTitleFilter: titleFilter)
        } else {
            updateNotebookViewModel()
        }
    }

    func didStartEditingTitle() {
        hidesBackButton = true
        updateNotebookViewModel()
    }

    func didFinishEditingTitle(newTitle title: String?) {
        hidesBackButton = false
        notebook = notebookUseCase.update(notebook, name: title ?? "")
            .recover(notebook)
        updateNotebookViewModel()
    }

    func didTapOnDeleteButton() {
        guard notebookUseCase.delete(notebook).error == nil else { return }
        navigationController.popViewController(animated: true)
    }
}

// MARK: - NoteViewControllerHandler

extension NotebookCoordinator: NoteViewControllerHandler {
    func didChangeContent(newContent: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = noteUseCase.update(activeNote, newContent: newContent)
            .recover(activeNote)
    }

    func didChangeTitle(newTitle: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = noteUseCase.update(activeNote, newTitle: newTitle)
            .recover(activeNote)
    }

    func onDeleteButtonClick() {
        guard let activeNote = activeNote else { return }
        guard noteUseCase.delete(activeNote).error == nil else { return }
        self.activeNote = nil
        navigationController.popViewController(animated: true)
    }

    func didAddTag(tag: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = noteUseCase.addTag(tag: tag, toNote: activeNote)
            .recover(activeNote)
    }

    func didRemoveTag(tag: String) {
        guard let activeNote = activeNote else { return }
        self.activeNote = noteUseCase.removeTag(tag: tag, fromNote: activeNote)
            .recover(activeNote)
    }

    func willDisappear() {
        updateNotebookViewModel()
    }
}
