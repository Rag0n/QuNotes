//
//  AppDelegate.swift
//  QuNotes
//
//  Created by Alexander Guschin on 09.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

final class AppDelegate: UIResponder, UIApplicationDelegate {
    var coordinator: AppCoordinator!

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        coordinator = AppCoordinator(withWindow: UIWindow(frame: UIScreen.main.bounds))
        coordinator.onStart()
        return false
    }
}

