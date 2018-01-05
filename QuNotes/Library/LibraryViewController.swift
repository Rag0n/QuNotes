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
    public func perform(effect: Library.ViewEffect) {
        switch effect {
        case .updateAllNotebooks(let notebooks):
            self.notebooks = notebooks
            tableView.reloadData()
        case .addNotebook(let index, let notebooks):
            self.notebooks = notebooks
            let indexPath = IndexPath(row: index, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .deleteNotebook(let index, let notebooks):
            self.notebooks = notebooks
            let indexPath = IndexPath(row: index, section: 0)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    public init(withDispatch dispatch: @escaping Library.ViewDispacher) {
        self.dispatch = dispatch
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        view = UIView()
        view.flex.alignItems(.center).define {
            $0.addItem(tableView).grow(1)
            $0.addItem(addButton).position(.absolute).bottom(20)
        }

        navigationItem.title = "library_title".localized
        tableView.dataSource = self
        tableView.delegate = self
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.flex.layout()
    }

    // MARK: - Private

    fileprivate enum Constants {
        static let libraryCellReuseIdentifier = "libraryCellReuseIdentifier"
    }
    
    fileprivate var notebooks: [Library.NotebookViewModel]!
    fileprivate var dispatch: Library.ViewDispacher

    private let tableView: UITableView = {
        let result = UITableView()
        LibraryTableViewCell.registerFor(tableView: result, reuseIdentifier: Constants.libraryCellReuseIdentifier)
        let theme = AppEnvironment.current.theme
        result.backgroundColor = theme.ligherDarkColor
        result.separatorColor = theme.textColor.withAlphaComponent(0.5)
        result.rowHeight = 44
        return result
    }()
    private let addButton: UIButton = {
        let result = UIButton(type: .system)
        result.setTitle("library_add_notebook_button".localized, for: .normal)
        result.addTarget(self, action: #selector(LibraryViewController.addNotebookButtonDidTap), for: .touchUpInside)
        return result
    }()

    @objc private func addNotebookButtonDidTap() {
        dispatch <| .addNotebook
    }
}

// MARK: - UITableViewDataSource

extension LibraryViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebooks?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.libraryCellReuseIdentifier, for: indexPath) as! LibraryTableViewCell
        cell.render(viewModel: notebooks[indexPath.row])
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
        let action = UIContextualAction(style: .destructive, title: "library_delete_notebook_button".localized) { [unowned self] (action, view, success) in
            self.dispatch <| .deleteNotebook(index: indexPath.row)
            success(true)
        }
        action.backgroundColor = .red
        return action
    }
}
