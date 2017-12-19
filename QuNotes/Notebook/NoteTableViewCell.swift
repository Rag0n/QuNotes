//
//  NoteTableViewCell.swift
//  QuNotes
//
//  Created by Alexander Guschin on 14.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

final class NoteTableViewCell: UITableViewCell {
    static func registerFor(tableView: UITableView, reuseIdentifier: String) {
        tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        let theme = AppEnvironment.current.theme
        titleLabel.textColor = theme.textColor
        titleLabel.backgroundColor = theme.ligherDarkColor
        titleLabel.highlightedTextColor = theme.darkColor
        contentView.backgroundColor = theme.ligherDarkColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(title: String) {
        titleLabel.text = title
    }

    private let titleLabel = UILabel()
}
