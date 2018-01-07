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
        contentView.backgroundColor = AppEnvironment.current.theme.ligherDarkColor
        contentView.flex.padding(8).minHeight(44).define {
            $0.addItem(titleLabel).grow(1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.flex.layout(mode: .adjustHeight)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.frame = CGRect(origin: contentView.frame.origin, size: size)
        contentView.flex.layout(mode: .adjustHeight)
        return contentView.frame.size
    }

    func render(viewModel: Library.NotebookViewModel) {
        titleLabel.text = viewModel.title
        titleLabel.flex.markDirty()
    }

    // MARK: - Private

    private let titleLabel: UILabel = {
        let l = UILabel()
        let theme = AppEnvironment.current.theme
        l.textColor = theme.textColor
        l.numberOfLines = 0
        return l
    }()
}
