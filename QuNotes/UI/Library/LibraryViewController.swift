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
    @IBOutlet private weak var tableView: UITableView?

    fileprivate enum Constants {
        static let title = "Library"
        static let libraryCellReuseIdentifier = "libraryCellReuseIdentifier"
    }

    @IBAction private func addNotebookButtonDidTap() {
        handler?.didTapAddNotebook()
    }

    private func setupTableView() {
        LibraryTableViewCell.registerFor(tableView: tableView!, reuseIdentifier: Constants.libraryCellReuseIdentifier)
        tableView!.estimatedRowHeight = 0
    }
}

// MARK: - UITableViewDataSource

extension LibraryViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.notebooks.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.libraryCellReuseIdentifier, for: indexPath) as! LibraryTableViewCell
        cell.set(title: viewModel?.notebooks[indexPath.row] ?? "")
        return cell
    }
}
