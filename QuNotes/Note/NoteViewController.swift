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
        case let .updateCells(cells):
            break
            self.content = content
            // TODO: prototype solution, need to fix it.
            // Need to just mark cells as dirty so it resizes
            // Also there is issue with reloading because it causes to resign first responder
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NoteTableViewCell else {
                break
            }
            cell.set(content: content) { [unowned self] newContent in
                self.dispatch(.changeContent(newContent, index: 0))
            }
            tableView.beginUpdates()
            tableView.endUpdates()
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
            $0.addItem(tableView).grow(1)
        }
        view.addSubview(container)

        setupNavigationBar()
        setupTagView()
        tableView.dataSource = self
        tableView.delegate = self
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
        static let noteCellReuseIdentifier = "noteCellReuseIdentifier"
    }
    fileprivate var dispatch: Note.ViewDispacher
    fileprivate var content: String = ""

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
    private let tableView: UITableView = {
        let t = UITableView()
        NoteTableViewCell.registerFor(tableView: t, reuseIdentifier: Constants.noteCellReuseIdentifier)
        t.estimatedRowHeight = 44
        let theme = AppEnvironment.current.theme
        t.backgroundColor = theme.ligherDarkColor
        t.separatorColor = theme.textColor.withAlphaComponent(0.5)
        t.allowsSelection = false
        return t
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

// MARK: - UITableViewDataSource

extension NoteViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.noteCellReuseIdentifier, for: indexPath) as! NoteTableViewCell
        cell.set(content: content) { [unowned self] newContent in
            self.dispatch(.changeContent(newContent, index: 0))
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NoteViewController: UITableViewDelegate {
}
