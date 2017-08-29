//
//  ThemeManager.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.08.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

struct ThemeManager {
    static func applyThemeForWindow(window: UIWindow) {
        let theme = DefaultTheme()
        window.tintColor = theme.mainColor

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: theme.textColor]
        let navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = theme.darkColor
        navigationBar.tintColor = theme.mainColor
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.textColor]
        navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.textColor]
    }
}
