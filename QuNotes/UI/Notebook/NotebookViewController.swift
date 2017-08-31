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
}

class NotebookViewController: UIViewController {

    func inject(handler: NotebookViewControllerHandler) {
        self.handler = handler
    }

    func render(withViewModel viewModel: NotebookViewModel) {
        self.viewModel = viewModel
        tableView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.title
        setupTableView()
        setupSearchController()
    }

    private func setupTableView() {
        tableView!.register(UITableViewCell.self, forCellReuseIdentifier: Constants.noteCellReuseIdentifier)
        tableView!.estimatedRowHeight = 0
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
    }

    fileprivate weak var handler: NotebookViewControllerHandler?
    fileprivate var viewModel: NotebookViewModel?
    
    @IBOutlet private weak var tableView: UITableView?
    @IBOutlet private weak var addButton: UIButton?
    private let searchController = UISearchController(searchResultsController: nil)

    @IBAction private func addNote() {
        handler?.didTapAddNote()
    }
}

extension NotebookViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.notes.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.noteCellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = viewModel?.notes[indexPath.row]

        return cell
    }
}

extension NotebookViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handler?.didTapOnNoteWithIndex(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, success) in
            let result = self.handler?.didSwapeToDeleteNoteWithIndex(index: indexPath.row) ?? false
            success(result)
        }
        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}

extension NotebookViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        handler?.didUpdateSearchResults(withText: searchController.searchBar.text)
    }
}
