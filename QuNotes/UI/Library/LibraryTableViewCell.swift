//
//  LibraryTableViewCell.swift
//  QuNotes
//
//  Created by Alexander Guschin on 25.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {
    // MARK: - API

    func render(viewModel: NotebookCellViewModel) {
        titleTextField.text = viewModel.title
        titleTextField.isEnabled = viewModel.isEditable
        if (viewModel.isEditable) {
            titleTextField.becomeFirstResponder()
        }
    }

    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = ThemeManager.defaultTheme()
        backgroundColor = theme.ligherDarkColor
        let attributes = [NSAttributedStringKey.foregroundColor: theme.textColor.withAlphaComponent(0.55)]
        titleTextField.attributedPlaceholder = NSAttributedString(string: "New notebook", attributes: attributes)
    }

    // MARK: - Private

    @IBOutlet private weak var titleTextField: UITextField!
}
