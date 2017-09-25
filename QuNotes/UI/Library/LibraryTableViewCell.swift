//
//  LibraryTableViewCell.swift
//  QuNotes
//
//  Created by Alexander Guschin on 25.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class LibraryTableViewCell: UITableViewCell {
    // MARK: - API

    func set(title: String) {
        titleLabel.text = title
    }

    // MARK: - Private

    @IBOutlet private weak var titleLabel: UILabel!
}
