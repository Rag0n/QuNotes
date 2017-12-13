//
//  LibraryTableViewCell.swift
//  QuNotes
//
//  Created by Alexander Guschin on 25.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

typealias DidChangeTitleBlock = (_ title: String?) -> Void

final class LibraryTableViewCell: UITableViewCell {
    // MARK: - API

    func render(viewModel: UI.Library.NotebookViewModel, onDidChangeTitle: @escaping DidChangeTitleBlock) {
        self.onDidChangeTitle = onDidChangeTitle
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
    private var onDidChangeTitle: DidChangeTitleBlock?
}

// MARK: - UITextFieldDelegate

extension LibraryTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        onDidChangeTitle?(textField.text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
