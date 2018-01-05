//
//  LibraryTableViewCell.swift
//  QuNotes
//
//  Created by Alexander Guschin on 25.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import FlexLayout

final class LibraryTableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = AppEnvironment.current.theme.ligherDarkColor
        contentView.flex.padding(8).define {
            $0.addItem(titleLabel).grow(1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.flex.layout(mode: .fitContainer)
    }

    func render(viewModel: Library.NotebookViewModel) {
        titleLabel.text = viewModel.title
        titleLabel.flex.markDirty()
    }

    // MARK: - Private

    private let titleLabel: UILabel = {
        let result = UILabel()
        let theme = AppEnvironment.current.theme
        result.textColor = theme.textColor
        result.numberOfLines = 0
        return result
    }()
}
