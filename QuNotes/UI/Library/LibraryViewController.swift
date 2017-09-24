//
//  LibraryViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    // MARK: - API

    func render(withViewModel viewModel: LibraryViewModel) {
        self.viewModel = viewModel
        tableView?.reloadData()
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.title
        if let viewModel = viewModel {
            render(withViewModel: viewModel)
        }
    }

    // MARK: - Private

    fileprivate var viewModel: LibraryViewModel?
    @IBOutlet private weak var tableView: UITableView?

    fileprivate enum Constants {
        static let title = "Library"
    }
}

// MARK: - UITableViewDataSource

extension LibraryViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.notebooks.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel?.notebooks[indexPath.row] ?? ""
        return cell
    }
}
