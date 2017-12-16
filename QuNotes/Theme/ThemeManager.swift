//
//  ThemeManager.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.08.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

public struct ThemeManager {
    // MARK: - API

    public static func applyTheme(forView view: UIView) {
        view.tintColor = theme.mainColor
        applyThemeForTextFields()
        applyThemeForNavigationBar()
        applyThemeForNotebookView()
        applyThemeForNoteCellView()
        applyThemeForLibraryView()
        applyThemeForLibraryCellView()
    }

    public static func defaultTheme() -> DefaultTheme {
        return DefaultTheme()
    }

    // MARK: - Private

    private static let theme = ThemeManager.defaultTheme()

    private static func applyThemeForTextFields() {
        let textField = UITextField.appearance()
        textField.keyboardAppearance = .dark
    }

    private static func applyThemeForNavigationBar() {
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: theme.textColor]
        let navigationBar = UINavigationBar.appearance()
        navigationBar.barTintColor = theme.darkColor
        navigationBar.tintColor = theme.mainColor
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.textColor]
        navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.textColor]
        let textField = UITextField.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        textField.textColor = theme.textColor
    }

    private static func applyThemeForNotebookView() {
        let notebookTableView = UITableView.appearance(whenContainedInInstancesOf: [NotebookViewController.self])
        notebookTableView.separatorColor = theme.textColor.withAlphaComponent(0.5)
    }

    private static func applyThemeForNoteCellView() {
        let noteTableViewCellLabel = UILabel.appearance(whenContainedInInstancesOf: [NoteTableViewCell.self])
        noteTableViewCellLabel.textColor = theme.textColor
        noteTableViewCellLabel.backgroundColor = theme.ligherDarkColor
        noteTableViewCellLabel.highlightedTextColor = theme.darkColor
        UIView.appearance(whenContainedInInstancesOf: [NoteTableViewCell.self]).backgroundColor = theme.ligherDarkColor
    }

    private static func applyThemeForLibraryView() {
        let notebookTableView = UITableView.appearance(whenContainedInInstancesOf: [LibraryViewController.self])
        notebookTableView.separatorColor = theme.textColor.withAlphaComponent(0.5)
    }

    private static func applyThemeForLibraryCellView() {
        UITextField.appearance(whenContainedInInstancesOf: [LibraryTableViewCell.self]).textColor = theme.textColor
    }
}
