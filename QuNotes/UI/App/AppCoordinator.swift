//
// Created by Alexander Guschin on 27.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    // MARK: - Coordinator

    func onStart() {
        configureWindow()
        showLibrary()
    }

    var rootViewController: UIViewController {
        get {
            return navigationController
        }
    }

    // MARK: - Life cycle

    init(withWindow window: UIWindow) {
        self.window = window
        ThemeManager.applyThemeForWindow(window: window)
    }

    // MARK: - Private

    private let window: UIWindow

    private lazy var dependency: AppDependency = {
        let fileReaderService = FileReaderServiceImp()
        let fileNoteRepository = FileNoteRepository()
        fileNoteRepository.fileManager = FileManager.default
        fileNoteRepository.fileReader = fileReaderService
        let currentDateService = CurrentDateServiceImp()
        let noteUseCase = NoteUseCase()
        noteUseCase.repository = fileNoteRepository
        noteUseCase.currentDateService = currentDateService

        let notebookUseCase = NotebookUseCase()

        return AppDependency(noteUseCase: noteUseCase, notebookUseCase: notebookUseCase)
    }()

    private lazy var navigationController: NavigationController = {
        let vc = NavigationController()
        vc.preferLargeTitles()
        return vc
    }()

    private func configureWindow() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    private func showLibrary() {
        let libraryCoordinator = LibraryCoordinator()
        navigationController.pushCoordinator(coordinator: libraryCoordinator, animated: true)
    }

    private func showNotebook() {
        let notebookCoordinator = NotebookCoordinator(withNavigationController: navigationController, dependencies: dependency)
        navigationController.pushCoordinator(coordinator: notebookCoordinator, animated: true)
    }
}
