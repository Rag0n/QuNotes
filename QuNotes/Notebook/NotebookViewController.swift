//
//  NotebookViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 17.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Prelude
import FlexLayout

final public class NotebookViewController: UIViewController {
    public func perform(effect: Notebook.ViewEffect) {
        switch effect {
        case let .updateAllNotes(notes):
            self.notes = notes
            tableView.reloadData()
        case .hideBackButton:
            navigationItem.setHidesBackButton(true, animated: true)
        case .showBackButton:
            navigationItem.setHidesBackButton(false, animated: true)
        case let .updateTitle(title):
            titleTextField.text = title
        case let .deleteNote(index, notes):
            self.notes = notes
            let indexPath = IndexPath(row: index, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case let .addNote(index, notes):
            self.notes = notes
            let indexPath = IndexPath(row: index, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    public init(withDispatch dispatch: @escaping Notebook.ViewDispacher) {
        self.dispatch = dispatch
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = UIView()
        view.flex.alignItems(.center).define {
            $0.addItem(tableView).grow(1)
            $0.addItem(addButton).position(.absolute).bottom(20)
        }

        setupNavigationBar()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        dispatch <| .didLoad
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.flex.layout()
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory else { return }
        addButton.flex.markDirty()
    }

    // MARK: - Private

    fileprivate enum Constants {
        static let estimatedCellHeight: CGFloat = 44
        static let notebookCellReuseIdentifier = "notebookCellReuseIdentifier"
    }

    fileprivate var dispatch: Notebook.ViewDispacher
    fileprivate var notes: [String]!

    private lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchResultsUpdater = self
        s.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.navigationItem.searchController = s
        return s
    }()
    private let tableView: UITableView = {
        let t = UITableView()
        NotebookTableViewCell.registerFor(tableView: t, reuseIdentifier: Constants.notebookCellReuseIdentifier)
        t.estimatedRowHeight = Constants.estimatedCellHeight
        let theme = AppEnvironment.current.theme
        t.backgroundColor = theme.ligherDarkColor
        t.separatorColor = theme.textColor.withAlphaComponent(0.5)
        return t
    }()
    private let addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("notebook_add_note_button".localized, for: .normal)
        b.titleLabel!.font = UIFont.preferredFont(forTextStyle: .headline)
        b.titleLabel!.adjustsFontForContentSizeCategory = true
        b.addTarget(self, action: #selector(NotebookViewController.addNote), for: .touchUpInside)
        return b
    }()
    private let titleTextField: UITextField = {
        let t =  UITextField(frame: CGRect(x: 0, y: 0, width: 120, height: 22))
        t.textAlignment = .center
        t.keyboardAppearance = .dark
        t.returnKeyType = .done
        t.keyboardType = .asciiCapable
        let attributes = [NSAttributedStringKey.foregroundColor: AppEnvironment.current.theme.textColor.withAlphaComponent(0.55)]
        t.attributedPlaceholder = NSAttributedString(string: "notebook_title_placeholder".localized,
                                                     attributes: attributes)
        return t
    }()

    private func setupNavigationBar() {
        addTitleTextField()
        addDeleteButton()
        addSearchController()
    }

    private func addTitleTextField() {
        titleTextField.delegate = self
        navigationItem.titleView = titleTextField
    }

    private func addDeleteButton() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(NotebookViewController.onDeleteButtonClick))
        self.navigationItem.rightBarButtonItem = deleteButton
    }

    private func addSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }

    @objc private func addNote() {
        dispatch <| .addNote
    }

    @objc private func onDeleteButtonClick() {
        dispatch <| .deleteNotebook
    }
}

// MARK: - UITableViewDataSource

extension NotebookViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.notebookCellReuseIdentifier, for: indexPath) as! NotebookTableViewCell
        cell.set(title: notes[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotebookViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatch <| .selectNote(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = deleteContextualAction(forIndexPath: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    private func deleteContextualAction(forIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "notebook_delete_note_button".localized) { [unowned self] (action, view, success) in
            self.dispatch <| .deleteNote(index: indexPath.row)
            success(true)
        }
        action.backgroundColor = .red
        return action
    }
}

// MARK: - UISearchResultsUpdating

extension NotebookViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        dispatch <| .filterNotes(filter: searchController.searchBar.text)
    }
}

// MARK: - UITextField

extension NotebookViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        dispatch <| .didStartToEditTitle
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        dispatch <| .didFinishToEditTitle(newTitle: textField.text)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
