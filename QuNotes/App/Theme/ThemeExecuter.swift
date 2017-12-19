//
//  ThemeExecuter.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.08.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

public struct ThemeExecuter {
    /// Apply theme to global UIKit components, such as NavigationBar
    /// Should be manually called after global theme updates
    ///
    /// - Parameter view: view on which tint color should be updated
    public static func applyTheme(forView view: UIView) {
        let theme = AppEnvironment.current.theme

        view.tintColor = theme.mainColor

        UITextField.appearance().keyboardAppearance = theme.keyboardAppearance

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: theme.textColor]
        let navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = theme.darkColor
        navigationBar.tintColor = theme.mainColor
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.textColor]
        navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.textColor]
        let textField = UITextField.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        textField.textColor = theme.textColor
    }
}
