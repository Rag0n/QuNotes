//
// Created by Alexander Guschin on 27.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class AppCoordinator {

    private let window: UIWindow

    init(withWindow window: UIWindow) {
        self.window = window
    }

    func start() {
        let notebookVC = NotebookViewController()
        window.rootViewController = notebookVC
        window.makeKeyAndVisible()
    }
}