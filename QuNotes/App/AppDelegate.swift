//
//  AppDelegate.swift
//  QuNotes
//
//  Created by Alexander Guschin on 09.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let coordinator: AppCoordinator = {
        return AppCoordinator(withWindow: UIWindow(frame: UIScreen.main.bounds))
    }()

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        coordinator.onStart()
        return true
    }
}

