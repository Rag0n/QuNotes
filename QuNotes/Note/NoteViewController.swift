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
import FlexLayout

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
            invalidateTagLayout()
        case let .addTag(tag):
            tagView.addTag(tag)
            invalidateTagLayout()
        case let .removeTag(tag):
            tagView.removeTag(tag)
            invalidateTagLayout()
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

    public override func loadView() {
        view = UIView()
        view.backgroundColor = .black

        container.flex.define {
            $0.addItem(titleTextField).height(scaledTitleTextFieldHeight)
            $0.addItem(tagView).maxHeight(80)
            $0.addItem(editor).grow(1)
        }
        view.addSubview(container)

        setupNavigationBar()
        setupTagView()
        editor.delegate = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        dispatch(.didLoad)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.frame = view.safeAreaLayoutGuide.layoutFrame
        container.flex.layout()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory else { return }
        titleTextField.flex.height(scaledTitleTextFieldHeight)
    }

    // MARK: - Private

    private enum Constants {
        static let themeName = "one-dark"
        static let titleTextFieldHeight: CGFloat = 20
    }
    fileprivate var dispatch: Note.ViewDispacher

    private var scaledTitleTextFieldHeight: CGFloat {
        return UIFontMetrics(forTextStyle: .body).scaledValue(for: Constants.titleTextFieldHeight)
    }

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = AppEnvironment.current.theme.ligherDarkColor
        return v
    }()
    private let titleTextField: UITextField = {
        let t = UITextField()
        let theme = AppEnvironment.current.theme
        t.backgroundColor = theme.ligherDarkColor
        t.textColor = theme.textColor
        t.attributedPlaceholder = NSAttributedString(string: "note_title_placeholder".localized,
                                                     attributes: [NSAttributedStringKey.foregroundColor: theme.textColor])
        t.font = UIFont.preferredFont(forTextStyle: .body)
        t.adjustsFontForContentSizeCategory = true
        t.addTarget(self, action: #selector(NoteViewController.onTitleTextFieldChange), for: .editingChanged)
        return t
    }()
    private let tagView: WSTagsField = {
        let t = WSTagsField(frame: .zero)
        t.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        t.spaceBetweenTags = 10.0
        t.font = .systemFont(ofSize: 12.0)
        let theme = AppEnvironment.current.theme
        t.textColor = theme.textColor
        t.fieldTextColor = theme.textColor
        t.selectedColor = theme.ligherDarkColor
        t.selectedTextColor = theme.textColor
        t.backgroundColor = theme.ligherDarkColor
        return t
    }()
    private let editor: Notepad = {
        let n = Notepad(frame: CGRect.zero, themeFile: Constants.themeName)
        n.keyboardAppearance = .dark
        n.returnKeyType = .done
        return n
    }()

    private func setupNavigationBar() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(NoteViewController.onDeleteButtonClick))
        navigationItem.rightBarButtonItem = deleteButton
    }

    private func setupTagView() {
        tagView.onDidAddTag = { [unowned self] _, tag in
            self.dispatch(.addTag(tag.text))
        }
        tagView.onDidRemoveTag = { [unowned self] _, tag in
            self.dispatch(.removeTag(tag.text))
        }
    }

    private func invalidateTagLayout() {
        tagView.flex.markDirty()
        view.setNeedsLayout()
    }

    @objc private func onDeleteButtonClick() {
        dispatch(.delete)
    }

    @objc private func onTitleTextFieldChange() {
        dispatch(.changeTitle(titleTextField.text ?? ""))
    }
}

// MARK: - UITextViewDelegate

extension NoteViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        dispatch(.changeContent(textView.text ?? ""))
    }
}
