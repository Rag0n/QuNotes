//
// Created by Alexander Guschin on 27.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    // MARK: - Coordinator

    func onStart() {
        configureWindow()
        showNotebook()
    }

    var rootViewController: UIViewController {
        get {
            return navigationController
        }
    }

    // MARK: - Life cycle

    init(withWindow window: UIWindow) {
        self.window = window
        let fileReaderService = FileReaderServiceImp()
        let fileNoteRepository = FileNoteRepository(withFileManager: FileManager.default, fileReader: fileReaderService)
        let currentDateService = CurrentDateServiceImp()
        let noteUseCase = NoteUseCase(withNoteReposiroty: fileNoteRepository, currentDateService: currentDateService)
        dependency = AppDependency(noteUseCase: noteUseCase)
    }

    // MARK: - Private

    private let window: UIWindow
    private let dependency: AppDependency

    private lazy var navigationController: NavigationViewController = {
        let vc = NavigationViewController()
        vc.preferLargeTitles()
        return vc
    }()

    private func configureWindow() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    private func showNotebook() {
        let notebookCoordinator = NotebookCoordinator(withNavigationController: navigationController, dependencies: dependency)
        navigationController.pushCoordinator(coordinator: notebookCoordinator, animated: true)
    }
}
