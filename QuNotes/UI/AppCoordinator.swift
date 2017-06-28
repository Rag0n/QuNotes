//
// Created by Alexander Guschin on 27.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class AppCoordinator {

    private let window: UIWindow

    fileprivate var navigationController: UINavigationController!
    fileprivate var childCoordinators = [NotebookCoordinator]()

    init(withWindow window: UIWindow) {
        self.window = window
    }

    func start() {
        initializeNavigationController()
        showNotebook()
    }

    private func initializeNavigationController() {
        navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showNotebook() {
        let notebookCoordinator = NotebookCoordinator(withNavigationController: navigationController)
        childCoordinators.append(notebookCoordinator)
        notebookCoordinator.start()
    }
}
