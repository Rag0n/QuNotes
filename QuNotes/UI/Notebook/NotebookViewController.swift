//
//  NotebookViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 17.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

protocol NotebookViewControllerHandler: class {
    func didTapAddNote()
    func didTapOnNoteWithIndex(index: Int)
    func didSwapeToDeleteNoteWithIndex(index: Int) -> Bool
    func didUpdateSearchResults(withText text: String?)
    func didStartEditingTitle()
    func didFinishEditingTitle(newTitle title: String?)
}

class NotebookViewController: UIViewController {
    // MARK: - API

    func inject(handler: NotebookViewControllerHandler) {
        self.handler = handler
    }

    func render(withViewModel viewModel: NotebookViewModel) {
        self.viewModel = viewModel
        reloadNavigationBar()
        tableView?.reloadData()
    }

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupSearchController()
    }

    // MARK: - Private

    private func reloadNavigationBar() {
        guard let viewModel = viewModel else { return }
        titleTextField?.text = viewModel.title
        navigationItem.setHidesBackButton(viewModel.hidesBackButton, animated: true)
    }

    private func setupNavigationBar() {
        titleTextField =  UITextField(frame: CGRect(x: 0, y: 0, width: 120, height: 22))
        titleTextField.delegate = self
        navigationItem.titleView = titleTextField
        reloadNavigationBar()
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

    fileprivate enum Constants {
        static let title = "Notes"
        static let noteCellReuseIdentifier = "noteCellReuseIdentifier"
        static let deleteActionTitle = "Delete"
    }

    fileprivate weak var handler: NotebookViewControllerHandler?
    fileprivate var viewModel: NotebookViewModel?
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addButton: UIButton!
    private var titleTextField: UITextField!
    private let searchController = UISearchController(searchResultsController: nil)

    @IBAction private func addNote() {
        handler?.didTapAddNote()
    }
}

// MARK: - UITableViewDataSource

extension NotebookViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.notes.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.noteCellReuseIdentifier, for: indexPath) as! NoteTableViewCell
        cell.set(title: viewModel?.notes[indexPath.row] ?? "")
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NotebookViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handler?.didTapOnNoteWithIndex(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: Constants.deleteActionTitle) { (action, view, success) in
            let result = self.handler?.didSwapeToDeleteNoteWithIndex(index: indexPath.row) ?? false
            success(result)
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
        handler?.didUpdateSearchResults(withText: searchController.searchBar.text)
    }
}

// MARK: - UITextField

extension NotebookViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        handler?.didStartEditingTitle()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        handler?.didFinishEditingTitle(newTitle: textField.text)
    }
}
