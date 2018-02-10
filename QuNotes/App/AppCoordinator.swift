//
// Created by Alexander Guschin on 27.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Prelude

final class AppCoordinator: Coordinator {
    // MARK: - Coordinator

    func onStart() {
        configureWindow()
        showLibrary()
    }

    var viewController: UIViewController {
        return navigationController
    }

    let output = 0

    // MARK: - Life cycle

    init(withWindow window: UIWindow) {
        self.window = window
        ThemeExecuter.applyTheme(forView: window)
    }

    // MARK: - Private

    private let window: UIWindow

    private let navigationController: NavigationController = {
        let vc = NavigationController()
        vc.preferLargeTitles()
        return vc
    }()

    private func configureWindow() {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    private func showLibrary() {
        let libraryCoordinator = Library.CoordinatorImp(withNavigationController: navigationController)
        navigationController.pushCoordinator(coordinator: libraryCoordinator, animated: true)
    }
}
