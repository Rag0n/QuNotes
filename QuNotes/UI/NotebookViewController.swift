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
}

class NotebookViewController: UIViewController {

    func inject(handler: NotebookViewControllerHandler) {
        self.handler = handler
    }

    func render(withViewModel viewModel: NotebookViewModel) {
        self.viewModel = viewModel
        tableView.reloadData()
    }

    fileprivate weak var handler: NotebookViewControllerHandler?
    fileprivate var viewModel: NotebookViewModel?
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addButton: UIButton!

    @IBAction private func addNote() {
        handler?.didTapAddNote()
    }
}

extension NotebookViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.notes.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = viewModel?.notes[indexPath.row]

        return cell
    }
}

extension NotebookViewController: UITableViewDelegate {

}
