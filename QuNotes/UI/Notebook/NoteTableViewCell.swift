//
//  NoteTableViewCell.swift
//  QuNotes
//
//  Created by Alexander Guschin on 14.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!

    func set(title: String) {
        titleLabel.text = title
    }
}
