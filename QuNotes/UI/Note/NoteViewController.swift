//
//  NoteViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 29.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Notepad
import WSTagsField

class NoteViewController: UIViewController {
    // MARK: - API

    func inject(dispatch: @escaping UI.Note.ViewControllerDispacher) {
        self.dispatch = dispatch
    }

    func perform(effect: UI.Note.ViewControllerEffect) {
        switch effect {
        case let .updateTitle(title):
            titleTextField?.text = title
        case let .updateContent(content):
            editor?.text = content
        case let .showTags(tags):
            tagView?.addTags(tags)
        case let .addTag(tag):
            tagView.addTag(tag)
        case let .removeTag(tag):
            tagView.removeTag(tag)
        case let .showError(error, message):
            let alertController = UIAlertController(title: error, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTagView()
        setupEditorTextView()
        setupNavigationBar()
        dispatch(.didLoad)
    }

    // MARK: - Private

    fileprivate var dispatch: UI.Note.ViewControllerDispacher!

    private enum Constants {
        static let themeName = "one-dark"
        static let backButtonIconName = "backIcon"
    }

    private var editor: Notepad!
    private var tagView: WSTagsField!
    @IBOutlet private var stackView: UIStackView! {
        didSet {
            stackView.backgroundColor = ThemeManager.defaultTheme().ligherDarkColor
        }
    }
    @IBOutlet private var titleTextField: UITextField! {
        didSet {
            let theme = ThemeManager.defaultTheme()
            titleTextField.backgroundColor = theme.ligherDarkColor
            titleTextField.textColor = theme.textColor
            let attributes = [
                NSAttributedStringKey.foregroundColor: theme.textColor
            ]
            titleTextField.attributedPlaceholder = NSAttributedString(string: titleTextField.placeholder!, attributes: attributes)
            titleTextField.addTarget(self,
                                     action: #selector(NoteViewController.onTitleTextFieldChange),
                                     for: .editingChanged)
        }
    }

    @objc private func onDeleteButtonClick() {
        dispatch(.delete)
    }

    @objc private func onTitleTextFieldChange() {
        dispatch(.changeTitle(newTitle: titleTextField.text ?? ""))
    }

    private func setupTagView() {
        tagView = WSTagsField()
        tagView.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tagView.spaceBetweenTags = 10.0
        tagView.font = .systemFont(ofSize: 12.0)
        let theme = ThemeManager.defaultTheme()
        tagView.textColor = theme.textColor
        tagView.fieldTextColor = theme.textColor
        tagView.selectedColor = theme.ligherDarkColor
        tagView.selectedTextColor = theme.textColor
        tagView.backgroundColor = theme.ligherDarkColor

        stackView.addArrangedSubview(tagView)
        subscribeOnChangeTagEvents()
    }

    private func subscribeOnChangeTagEvents() {
        tagView.onDidAddTag = { [unowned self] _, tag in
            self.dispatch(.addTag(tag: tag.text))
        }
        tagView.onDidRemoveTag = { [unowned self] _, tag in
            self.dispatch(.removeTag(tag: tag.text))
        }
    }

    private func setupEditorTextView() {
        editor = Notepad(frame: view.bounds, themeFile: Constants.themeName)
        editor.delegate = self
        editor.keyboardAppearance = .dark
        editor.returnKeyType = .done
        stackView.addArrangedSubview(editor)
    }

    private func setupNavigationBar() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(NoteViewController.onDeleteButtonClick))
        navigationItem.rightBarButtonItem = deleteButton
    }
}

// MARK: - UITextViewDelegate

extension NoteViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        dispatch(.changeContent(newContent: textView.text ?? ""))
    }
}
