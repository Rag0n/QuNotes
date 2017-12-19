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

    static func registerFor(tableView: UITableView, reuseIdentifier: String) {
        tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleTextField)
        let theme = AppEnvironment.current.theme
        backgroundColor = theme.ligherDarkColor
        let attributes = [NSAttributedStringKey.foregroundColor: theme.textColor.withAlphaComponent(0.55)]
        titleTextField.textColor = theme.textColor
        titleTextField.attributedPlaceholder = NSAttributedString(string: "New notebook", attributes: attributes)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            titleTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 8),
            titleTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    private let titleTextField = UITextField()
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
