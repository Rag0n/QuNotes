//
//  NotebookViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 17.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class NotebookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var noteUseCase: NoteUseCase!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        noteUseCase = NoteUseCase()
        noteUseCase.addNote(withContent: "First note")
        noteUseCase.addNote(withContent: "Second note")
    }

    // MARK: Actions

    @IBAction func addNote() {
        noteUseCase.addNote(withContent: "New note")
        tableView.reloadData()
    }

    // MARK: TableView

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteUseCase.getAllNotes().count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let allNotes = noteUseCase.getAllNotes()
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = allNotes[indexPath.row].content

        return cell
    }
}
