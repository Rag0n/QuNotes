//
//  TableViewCell+Extensions.swift
//  QuNotes
//
//  Created by Alexander Guschin on 27.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static func registerFor(tableView: UITableView, reuseIdentifier: String) {
        tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
    }
}
