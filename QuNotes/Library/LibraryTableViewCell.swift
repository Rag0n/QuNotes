//
//  LibraryTableViewCell.swift
//  QuNotes
//
//  Created by Alexander Guschin on 25.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import FlexLayout

typealias DidChangeTitleBlock = (_ title: String?) -> Void

final class LibraryTableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = AppEnvironment.current.theme.ligherDarkColor
        contentView.flex.padding(8).define {
            $0.addItem(titleTextField).grow(1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.flex.layout(mode: .fitContainer)
    }

    func render(viewModel: Library.NotebookViewModel, onDidChangeTitle: @escaping DidChangeTitleBlock) {
        self.onDidChangeTitle = onDidChangeTitle
        titleTextField.text = viewModel.title
        titleTextField.isEnabled = viewModel.isEditable
        if (viewModel.isEditable) {
            titleTextField.becomeFirstResponder()
        }
    }

    // MARK: - Private

    private let titleTextField: UITextField = {
        let result = UITextField()
        let theme = AppEnvironment.current.theme
        let attributes = [NSAttributedStringKey.foregroundColor: theme.textColor.withAlphaComponent(0.55)]
        result.textColor = theme.textColor
        result.attributedPlaceholder = NSAttributedString(string: "library_new_notebook_title_placeholder".localized,
                                                          attributes: attributes)
        return result
    }()
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
