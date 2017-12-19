//
//  LibraryViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import Prelude

final public class LibraryViewController: UIViewController {
    // MARK: - API

    public func perform(effect: Library.ViewEffect) {
        switch effect {
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
        }
    }

    // MARK: - Life cycle

    public init(withDispatch dispatch: @escaping Library.ViewDispacher) {
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
        navigationItem.title = Constants.title
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LibraryViewController.dismissKeyboard)))
    }

    // MARK: - Private

    private var tableView: UITableView!
    private var addButton: UIButton!
    fileprivate var notebooks: [Library.NotebookViewModel]!
    fileprivate var dispatch: Library.ViewDispacher

    fileprivate enum Constants {
        static let title = "Library"
        static let libraryCellReuseIdentifier = "libraryCellReuseIdentifier"
        static let deleteActionTitle = "Delete"
    }

    @objc private func addNotebookButtonDidTap() {
        dispatch <| .addNotebook
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func addTableView() {
        tableView = UITableView()
        LibraryTableViewCell.registerFor(tableView: tableView, reuseIdentifier: Constants.libraryCellReuseIdentifier)
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
        addButton.addTarget(self, action: #selector(LibraryViewController.addNotebookButtonDidTap), for: .touchUpInside)
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
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
            self.dispatch <| .updateNotebook(index: indexPath.row, title: title ?? "")
        })
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LibraryViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatch <| .selectNotebook(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = deleteContextualAction(forIndexPath: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    private func deleteContextualAction(forIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: Constants.deleteActionTitle) { [unowned self] (action, view, success) in
            self.dispatch <| .deleteNotebook(index: indexPath.row)
            success(true)
        }
        action.backgroundColor = .red
        return action
    }
}
