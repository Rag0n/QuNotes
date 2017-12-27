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

public final class NoteViewController: UIViewController {
    public func perform(effect: Note.ViewEffect) {
        switch effect {
        case let .updateTitle(title):
            titleTextField.text = title
        case .focusOnTitle:
            titleTextField.becomeFirstResponder()
        case let .updateContent(content):
            editor.text = content
        case let .showTags(tags):
            tagView.addTags(tags)
        case let .addTag(tag):
            tagView.addTag(tag)
        case let .removeTag(tag):
            tagView.removeTag(tag)
        }
    }

    // MARK: - Life cycle

    public init(withDispatch dispatch: @escaping Note.ViewDispacher) {
        self.dispatch = dispatch
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        view = UIView()
        view.backgroundColor = .white
        addStackView()
        addTilteTextField()
        addTagView()
        addEditorTextView()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        dispatch(.didLoad)
    }

    // MARK: - Private

    private func addStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = AppEnvironment.current.theme.ligherDarkColor
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func addTilteTextField() {
        titleTextField = UITextField()
        titleTextField.placeholder = "note_title_placeholder".localized
        let theme = AppEnvironment.current.theme
        titleTextField.backgroundColor = theme.ligherDarkColor
        titleTextField.textColor = theme.textColor
        let attributes = [
            NSAttributedStringKey.foregroundColor: theme.textColor
        ]
        titleTextField.attributedPlaceholder = NSAttributedString(string: titleTextField.placeholder!, attributes: attributes)
        titleTextField.addTarget(self, action: #selector(NoteViewController.onTitleTextFieldChange), for: .editingChanged)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.widthAnchor.constraint(equalToConstant: 20).isActive = true
        stackView.addArrangedSubview(titleTextField)
    }

    private func addTagView() {
        tagView = WSTagsField()
        tagView.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tagView.spaceBetweenTags = 10.0
        tagView.font = .systemFont(ofSize: 12.0)
        let theme = AppEnvironment.current.theme
        tagView.textColor = theme.textColor
        tagView.fieldTextColor = theme.textColor
        tagView.selectedColor = theme.ligherDarkColor
        tagView.selectedTextColor = theme.textColor
        tagView.backgroundColor = theme.ligherDarkColor

        stackView.addArrangedSubview(tagView)
        tagView.onDidAddTag = { [unowned self] _, tag in
            self.dispatch(.addTag(tag.text))
        }
        tagView.onDidRemoveTag = { [unowned self] _, tag in
            self.dispatch(.removeTag(tag.text))
        }
    }

    private func addEditorTextView() {
        editor = Notepad(frame: CGRect.zero, themeFile: Constants.themeName)
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

    // MARK: Actions

    @objc private func onDeleteButtonClick() {
        dispatch(.delete)
    }

    @objc private func onTitleTextFieldChange() {
        dispatch(.changeTitle(titleTextField.text ?? ""))
    }

    // MARK: Data

    private enum Constants {
        static let themeName = "one-dark"
    }

    fileprivate var dispatch: Note.ViewDispacher
    private var editor: Notepad!
    private var tagView: WSTagsField!
    private var stackView: UIStackView!
    private var titleTextField: UITextField!
}

// MARK: - UITextViewDelegate

extension NoteViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        dispatch(.changeContent(textView.text ?? ""))
    }
}
