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
        let theme = AppEnvironment.current.theme
        contentView.flex.padding(8).minHeight(44).backgroundColor(theme.ligherDarkColor).define {
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
        let result = UILabel()
        let theme = AppEnvironment.current.theme
        result.textColor = theme.textColor
        result.numberOfLines = 0
        return result
    }()
}
