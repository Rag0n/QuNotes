//
//  NotebookViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 17.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Prelude

final public class NotebookViewController: UIViewController {
    // MARK: - API

    public func perform(effect: Notebook.ViewEffect) {
        switch effect {
        case let .updateAllNotes(notes):
            self.notes = notes
            tableView?.reloadData()
        case .hideBackButton:
            navigationItem.setHidesBackButton(true, animated: true)
        case .showBackButton:
            navigationItem.setHidesBackButton(false, animated: true)
        case let .updateTitle(title):
            titleTextField?.text = title
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

    // MARK: - Life cycle

    public init(withDispatch dispatch: @escaping Notebook.ViewDispacher) {
        self.dispatch = dispatch
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        view = UIView()
        addTableView()
        addAddNoteButton()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        dispatch <| .didLoad
        tableView.reloadData()
    }

    // MARK: - Private

    fileprivate var dispatch: Notebook.ViewDispacher
    fileprivate var notes: [String]!

    private var tableView: UITableView!
    private var addButton: UIButton!
    private var titleTextField: UITextField!
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.navigationItem.searchController = controller
        return controller
    }()

    fileprivate enum Constants {
        static let title = "Notes"
        static let noteCellReuseIdentifier = "noteCellReuseIdentifier"
        static let deleteActionTitle = "Delete"
    }

    private func setupNavigationBar() {
        titleTextField =  UITextField(frame: CGRect(x: 0, y: 0, width: 120, height: 22))
        titleTextField.delegate = self
        titleTextField.textAlignment = .center
        titleTextField.keyboardAppearance = .dark
        titleTextField.returnKeyType = .done
        titleTextField.keyboardType = .asciiCapable
        navigationItem.titleView = titleTextField
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(NotebookViewController.onDeleteButtonClick))
        self.navigationItem.rightBarButtonItem = deleteButton
    }

    private func addTableView() {
        tableView = UITableView()
        NoteTableViewCell.registerFor(tableView: tableView, reuseIdentifier: Constants.noteCellReuseIdentifier)
        tableView.estimatedRowHeight = 0
        let theme = AppEnvironment.current.theme
        tableView.backgroundColor = theme.ligherDarkColor
        tableView.separatorColor = theme.textColor.withAlphaComponent(0.5)
        tableView.rowHeight = 44
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func addAddNoteButton() {
        addButton = UIButton(type: .system)
        addButton.setTitle("Add", for: .normal)
        addButton.addTarget(self, action: #selector(NotebookViewController.addNote), for: .touchUpInside)
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.noteCellReuseIdentifier, for: indexPath) as! NoteTableViewCell
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
        let action = UIContextualAction(style: .destructive, title: Constants.deleteActionTitle) { [unowned self] (action, view, success) in
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
