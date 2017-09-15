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
        let theme = ThemeManager.defaultTheme()
        window.tintColor = theme.mainColor

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: theme.textColor]
        let navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = theme.darkColor
        navigationBar.tintColor = theme.mainColor
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.textColor]
        navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.textColor]

        let notebookTableView = UITableView.appearance(whenContainedInInstancesOf: [NotebookViewController.self])
        notebookTableView.backgroundColor = theme.ligherDarkColor
        notebookTableView.separatorColor = theme.textColor.withAlphaComponent(0.5)

        let noteTableViewCellLabel = UILabel.appearance(whenContainedInInstancesOf: [NoteTableViewCell.self])
        noteTableViewCellLabel.textColor = theme.textColor
        noteTableViewCellLabel.backgroundColor = theme.ligherDarkColor
        noteTableViewCellLabel.highlightedTextColor = theme.darkColor
        UIView.appearance(whenContainedInInstancesOf: [NoteTableViewCell.self]).backgroundColor = theme.ligherDarkColor
    }

    static func defaultTheme() -> DefaultTheme {
        return DefaultTheme()
    }
}
