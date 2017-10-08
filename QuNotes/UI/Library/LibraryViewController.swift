//
//  LibraryViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

enum LibraryViewControllerEvent {
    case addNotebook
    case selectNotebook
    case deleteNotebook
}

enum LibraryViewControllerUpdate {
    case updateAllNotebooks(notebooks: [NotebookCellViewModel])
    case addNotebook(index: Int, notebooks: [NotebookCellViewModel])
    case updateNotebook(index: Int, notebooks:  [NotebookCellViewModel])
    case deleteNotebook(index: Int)
}

protocol LibraryViewControllerHandler: class {
    func didTapAddNotebook()
    func didTapOnNotebook(withIndex index: Int)
    func didSwapeToDeleteNotebook(withIndex index: Int) -> Bool
    func didChangeNameOfNotebook(withIndex index: Int, title: String)
}

typealias LibraryViewControllerDispacher = (_ event: LibraryViewControllerEvent) -> ()

class LibraryViewController: UIViewController {
    // MARK: - API

    func inject(handler: LibraryViewControllerHandler) {
        self.handler = handler
    }

    func render(withViewModel viewModel: LibraryViewModel) {
        self.viewModel = viewModel
        tableView?.reloadData()
    }

    func inject(dispatch: @escaping LibraryViewControllerDispacher) {
        self.dispatch = dispatch
    }

    func apply(update: LibraryViewControllerUpdate) {
        switch update {
        case .updateAllNotebooks(let notebooks):
            self.notebooks = notebooks
            tableView?.reloadData()
        case .updateNotebook(let index, let notebooks):
            self.notebooks = notebooks
            let indexPath = IndexPath(row: index, section: 0)
            tableView?.reloadRows(at: [indexPath], with: .automatic)
        case .addNotebook(let index, let notebooks):
            self.notebooks = notebooks
            let indexPath = IndexPath(row: index, section: 0)
            tableView?.insertRows(at: [indexPath], with: .automatic)
        case .deleteNotebook(let index):
            let indexPath = IndexPath(row: index, section: 0)
            tableView?.deleteRows(at: [indexPath], with: .automatic)
        }
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

    fileprivate var notebooks: [NotebookCellViewModel]!

    fileprivate var dispatch: LibraryViewControllerDispacher?

    fileprivate enum Constants {
        static let title = "Library"
        static let libraryCellReuseIdentifier = "libraryCellReuseIdentifier"
        static let deleteActionTitle = "Delete"
    }

    @IBAction private func addNotebookButtonDidTap() {
        dispatch?(.addNotebook)
    }

    @IBAction private func dismissKeyboard() {
        self.view.endEditing(true)
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
//        return viewModel?.notebooks.count ?? 0
        return notebooks?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.libraryCellReuseIdentifier, for: indexPath) as! LibraryTableViewCell
        cell.render(viewModel: notebooks[indexPath.row], onDidChangeTitle: { [unowned self] title in
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
