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
import Prelude

public final class NoteViewController: UIViewController {
    public func perform(effect: Note.ViewEffect) {
        switch effect {
        case let .updateTitle(title):
            titleTextField.text = title
        case .focusOnTitle:
            titleTextField.becomeFirstResponder()
        case let .updateCells(cells):
            self.cells = cells
            tableView.reloadData()
        case let .addCell(index, cells):
            self.cells = cells
            let indexPath = IndexPath(row: index, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        case let .removeCell(index, cells):
            self.cells = cells
            let indexPath = IndexPath(row: index, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case let .updateCell(index, cells):
            self.cells = cells
            reloadCell(withIndex: index)
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
            $0.addItem(titleTextField).height(scaledTitleTextFieldHeight).margin(0, 8, 0, 8)
            $0.addItem(tagView).maxHeight(80)
            $0.addItem(tableView).grow(1)
            $0.addItem(addButton).position(.absolute).alignSelf(.center).bottom(20)
        }
        view.addSubview(container)

        setupNavigationBar()
        setupTagView()
        setupKeyboardAvoidingBehaviour()
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
        static let estimatedNoteCellHeight: CGFloat = 44
        static let noteCellReuseIdentifier = "noteCellReuseIdentifier"
    }
    fileprivate var dispatch: Note.ViewDispacher
    fileprivate var cells: [Note.CellViewModel] = []

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
        t.addTarget(self, action: #selector(onTitleTextFieldChange), for: .editingChanged)
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
        t.estimatedRowHeight = Constants.estimatedNoteCellHeight
        let theme = AppEnvironment.current.theme
        t.backgroundColor = theme.ligherDarkColor
        t.separatorColor = theme.textColor.withAlphaComponent(0.5)
        t.allowsSelection = false
        return t
    }()
    private let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("note_add_content_cell_button".localized, for: .normal)
        b.titleLabel!.font = UIFont.preferredFont(forTextStyle: .headline)
        b.titleLabel!.adjustsFontForContentSizeCategory = true
        b.addTarget(self, action: #selector(addCell), for: .touchUpInside)
        return b
    }()

    private func setupNavigationBar() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(onDeleteButtonClick))
        navigationItem.rightBarButtonItem = deleteButton
    }

    private func setupTagView() {
        tagView.onDidAddTag = { [unowned self] _, tag in
            self.dispatch <| .addTag(tag.text)
        }
        tagView.onDidRemoveTag = { [unowned self] _, tag in
            self.dispatch <| .removeTag(tag.text)
        }
    }

    private func setupKeyboardAvoidingBehaviour() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardChangingFrame(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }

    private func invalidateTagLayout() {
        tagView.flex.markDirty()
        view.setNeedsLayout()
    }

    private func reloadCell(withIndex index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? NoteTableViewCell else { return }
        updateCell(cell, index: index)
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    private func updateCell(_ cell: NoteTableViewCell, index: Int) {
        let content = cells[index].content
        cell.set(content: content, maxHeight: tableView.bounds.size.height) { [unowned self] newContent in
            self.dispatch <| .changeCellContent(newContent, index: index)
        }
    }

    private func handleEditingEnd(_ cell: NoteTableViewCell) {
        cell.onEditingEnd = { [unowned cell] in
            cell.maxHeight = CGFloat.greatestFiniteMagnitude
        }
    }

    private func animateKeyboardInsets(forNotificationUserInfo userInfo: [AnyHashable: Any], intersection: CGRect) {
        guard let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        guard let animationCurveRaw = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else { return }
        let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.additionalSafeAreaInsets.bottom = intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func handleKeyboardChangingFrame(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        animateKeyboardInsets(forNotificationUserInfo: userInfo, intersection: intersection)
    }

    @objc private func onDeleteButtonClick() {
        dispatch <| .delete
    }

    @objc private func onTitleTextFieldChange() {
        dispatch <| .changeTitle(titleTextField.text ?? "")
    }

    @objc private func addCell() {
        dispatch <| .addCell
    }
}

// MARK: - UITableViewDataSource

extension NoteViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.noteCellReuseIdentifier, for: indexPath) as! NoteTableViewCell
        updateCell(cell, index: indexPath.row)
        handleEditingEnd(cell)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NoteViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = deleteContextualAction(forIndexPath: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    private func deleteContextualAction(forIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "note_delete_content_cell_button".localized) { [unowned self] (action, view, success) in
            self.dispatch(.removeCell(index: indexPath.row))
            success(true)
        }
        action.backgroundColor = .red
        return action
    }
}
