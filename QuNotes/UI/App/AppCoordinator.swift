//
// Created by Alexander Guschin on 27.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit

final class AppCoordinator: Coordinator {
    // MARK: - Coordinator

    func onStart() {
        configureWindow()
        showLibrary()
    }

    var viewController: UIViewController {
        return navigationController
    }

    // MARK: - Life cycle

    init(withWindow window: UIWindow) {
        self.window = window
        ThemeManager.applyThemeForWindow(window: window)
    }

    // MARK: - Private

    private let window: UIWindow

    private lazy var dependency: AppDependency = {
        let fileExecuter = FileExecuter()
        return AppDependency(fileExecuter: fileExecuter)
    }()

    private lazy var navigationController: NavigationController = {
        let vc = NavigationController()
        vc.preferLargeTitles()
        return vc
    }()

    private func configureWindow() {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    private func showLibrary() {
        let libraryCoordinator = UI.Library.CoordinatorImp(withNavigationController: navigationController, dependencies: dependency)
        navigationController.pushCoordinator(coordinator: libraryCoordinator, animated: true)
    }
}
