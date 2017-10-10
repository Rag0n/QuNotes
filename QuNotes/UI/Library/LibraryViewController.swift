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
    case selectNotebook(index: Int)
    case deleteNotebook(index: Int)
    case updateNotebook(index: Int, title: String)
}

enum LibraryViewControllerUpdate {
    case updateAllNotebooks(notebooks: [NotebookCellViewModel])
    case addNotebook(index: Int, notebooks: [NotebookCellViewModel])
    case updateNotebook(index: Int, notebooks:  [NotebookCellViewModel])
    case deleteNotebook(index: Int, notebooks: [NotebookCellViewModel])
    case showError(error: String, message: String)
}

typealias LibraryViewControllerDispacher = (_ event: LibraryViewControllerEvent) -> ()

class LibraryViewController: UIViewController {
    // MARK: - API

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
        case .deleteNotebook(let index, let notebooks):
            self.notebooks = notebooks
            let indexPath = IndexPath(row: index, section: 0)
            tableView?.deleteRows(at: [indexPath], with: .automatic)
        case .showError(let error, let message):
            let alertController = UIAlertController(title: error, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.title
        setupTableView()
    }

    // MARK: - Private
    @IBOutlet private weak var tableView: UITableView!
    fileprivate var notebooks: [NotebookCellViewModel]!
    fileprivate var dispatch: LibraryViewControllerDispacher!

    fileprivate enum Constants {
        static let title = "Library"
        static let libraryCellReuseIdentifier = "libraryCellReuseIdentifier"
        static let deleteActionTitle = "Delete"
    }

    @IBAction private func addNotebookButtonDidTap() {
        dispatch(.addNotebook)
    }

    @IBAction private func dismissKeyboard() {
        view.endEditing(true)
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
        return notebooks?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.libraryCellReuseIdentifier, for: indexPath) as! LibraryTableViewCell
        cell.render(viewModel: notebooks[indexPath.row], onDidChangeTitle: { [unowned self] title in
            self.dispatch(.updateNotebook(index: indexPath.row, title: title))
        })
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LibraryViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatch(.selectNotebook(index: indexPath.row))
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: Constants.deleteActionTitle) { [unowned self] (action, view, success) in
            self.dispatch(.deleteNotebook(index: indexPath.row))
            success(true)
        }
        deleteAction.backgroundColor = .red

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}
