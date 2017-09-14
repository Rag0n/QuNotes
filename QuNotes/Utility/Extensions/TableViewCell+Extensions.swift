//
//  TableViewCell+Extensions.swift
//  QuNotes
//
//  Created by Alexander Guschin on 14.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static func registerFor(tableView: UITableView, reuseIdentifier: String) {
        let nib = UINib(nibName: String(describing: self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
}
