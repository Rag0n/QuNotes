//
//  AppDelegate.swift
//  QuNotes
//
//  Created by Alexander Guschin on 09.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let notebookVC = NotebookViewController()

        let window = UIWindow(frame: UIScreen.main.bounds);
        window.rootViewController = notebookVC
        window.makeKeyAndVisible()
        self.window = window

        return false
    }
}

