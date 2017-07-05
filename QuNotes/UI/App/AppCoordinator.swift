//
// Created by Alexander Guschin on 27.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class AppCoordinator {

    private let window: UIWindow
    private let dependency: AppDependency

    fileprivate var navigationController: UINavigationController!
    fileprivate var childCoordinators = [NotebookCoordinator]()

    init(withWindow window: UIWindow) {
        self.window = window
        let fileNoteRepository = FileNoteRepository(withFileManager: FileManager.default)
        let currentDateService = CurrentDateServiceImp()
        let noteUseCase = NoteUseCase(withNoteReposiroty: fileNoteRepository, currentDateService: currentDateService)
        dependency = AppDependency(noteUseCase: noteUseCase)
    }

    func start() {
        initializeNavigationController()
        showNotebook()
    }

    private func initializeNavigationController() {
        navigationController = UINavigationController()
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showNotebook() {
        let notebookCoordinator = NotebookCoordinator(withNavigationController: navigationController, dependencies: dependency)
        childCoordinators.append(notebookCoordinator)
        notebookCoordinator.start()
    }
}
