//
//  AppDelegate.swift
//  QuNotes
//
//  Created by Alexander Guschin on 09.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var appCoordinator: AppCoordinator!

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        appCoordinator = AppCoordinator(withWindow: UIWindow(frame: UIScreen.main.bounds))
        appCoordinator.onStart()

        return false
    }
}

