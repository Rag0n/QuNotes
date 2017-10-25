//
//  NotebookViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 17.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class NotebookViewController: UIViewController {
    // MARK: - API

    func inject(dispatch: @escaping UI.Notebook.ViewControllerDispacher) {
        self.dispatch = dispatch
    }

    func perform(effect: UI.Notebook.ViewControllerEffect) {
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
            tableView?.deleteRows(at: [indexPath], with: .automatic)
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
        setupNavigationBar()
        setupTableView()
        setupSearchController()
        dispatch <| .didLoad
    }

    // MARK: - Private

    fileprivate var dispatch: UI.Notebook.ViewControllerDispacher!
    fileprivate var notes: [String]!

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addButton: UIButton!
    private var titleTextField: UITextField!
    private let searchController = UISearchController(searchResultsController: nil)

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

    private func setupTableView() {
        NoteTableViewCell.registerFor(tableView: tableView, reuseIdentifier: Constants.noteCellReuseIdentifier)
        tableView.estimatedRowHeight = 0
        tableView.backgroundColor = ThemeManager.defaultTheme().ligherDarkColor
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }

    @IBAction private func addNote() {
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

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
    func updateSearchResults(for searchController: UISearchController) {
        dispatch <| .filterNotes(filter: searchController.searchBar.text)
    }
}

// MARK: - UITextField

extension NotebookViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dispatch <| .didStartToEditTitle
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        dispatch <| .didFinishToEditTitle(newTitle: textField.text)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
