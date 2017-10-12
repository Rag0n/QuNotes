//
//  NotebookViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 17.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

extension NotebookNamespace {
    enum ViewControllerEvent {
        case addNote
        case selectNote(index: Int)
        case deleteNote(index: Int)
        case deleteNotebook
        case filterNotes(filter: String?)
        case didStartToEditTitle
        case didFinishToEditTitle(newTitle: String?)
    }
}

extension NotebookNamespace {
    enum ViewControllerUpdate {
        case updateAllNotes(notes: [String])
        case hideBackButton
        case showBackButton
    }
}

typealias NotebookViewControllerDispacher = (_ event: NotebookNamespace.ViewControllerEvent) -> ()

class NotebookViewController: UIViewController {
    // MARK: - API

    func inject(dispatch: @escaping NotebookViewControllerDispacher) {
        self.dispatch = dispatch
    }

    func apply(update: NotebookNamespace.ViewControllerUpdate) {
    }

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupSearchController()
    }

    // MARK: - Private

    fileprivate var notes: [String]!
    fileprivate var dispatch: NotebookViewControllerDispacher!

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
        dispatch(.addNote)
    }

    @objc private func onDeleteButtonClick() {
        dispatch(.deleteNotebook)
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
        dispatch(.selectNote(index: indexPath.row))
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: Constants.deleteActionTitle) { [unowned self] (action, view, success) in
            self.dispatch(.deleteNote(index: indexPath.row))
            success(true)
        }
        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}

// MARK: - UISearchResultsUpdating

extension NotebookViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        dispatch(.filterNotes(filter: searchController.searchBar.text))
    }
}

// MARK: - UITextField

extension NotebookViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dispatch(.didStartToEditTitle)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        dispatch(.didFinishToEditTitle(newTitle: textField.text))
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

