//
//  LibraryViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

protocol LibraryViewControllerHandler: class {
    func didTapAddNotebook()
    func didTapOnNotebook(withIndex index: Int)
    func didSwapeToDeleteNotebook(withIndex index: Int) -> Bool
    func didChangeNameOfNotebook(withIndex index: Int, title: String)
}

class LibraryViewController: UIViewController {
    // MARK: - API

    func inject(handler: LibraryViewControllerHandler) {
        self.handler = handler
    }

    func render(withViewModel viewModel: LibraryViewModel) {
        self.viewModel = viewModel
        tableView?.reloadData()
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.title
        setupTableView()
    }

    // MARK: - Private

    fileprivate weak var handler: LibraryViewControllerHandler?
    fileprivate var viewModel: LibraryViewModel?
    @IBOutlet private weak var tableView: UITableView!

    fileprivate enum Constants {
        static let title = "Library"
        static let libraryCellReuseIdentifier = "libraryCellReuseIdentifier"
        static let deleteActionTitle = "Delete"
    }

    @IBAction private func addNotebookButtonDidTap() {
        handler?.didTapAddNotebook()
    }

    private func setupTableView() {
        LibraryTableViewCell.registerFor(tableView: tableView, reuseIdentifier: Constants.libraryCellReuseIdentifier)
        tableView.estimatedRowHeight = 0
        tableView.backgroundColor = ThemeManager.defaultTheme().ligherDarkColor
    }
}

// MARK: - UITableViewDataSource

extension LibraryViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.notebooks.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.libraryCellReuseIdentifier, for: indexPath) as! LibraryTableViewCell
        cell.render(viewModel: viewModel!.notebooks[indexPath.row], onDidChangeTitle: { [unowned self] title in
            self.handler?.didChangeNameOfNotebook(withIndex: indexPath.row, title: title)
        })
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LibraryViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handler?.didTapOnNotebook(withIndex: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: Constants.deleteActionTitle) { (action, view, success) in
            let result = self.handler?.didSwapeToDeleteNotebook(withIndex: indexPath.row) ?? false
            success(result)
        }
        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}
