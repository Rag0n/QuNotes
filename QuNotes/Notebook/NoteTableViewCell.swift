//
//  NoteTableViewCell.swift
//  QuNotes
//
//  Created by Alexander Guschin on 14.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import FlexLayout

final class NoteTableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = AppEnvironment.current.theme.ligherDarkColor
        let scaledMinHeight = UIFontMetrics(forTextStyle: .body).scaledValue(for: minHeight)
        contentView.flex.minHeight(scaledMinHeight).define {
            $0.addItem(titleLabel).grow(1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.flex.padding(contentView.layoutMargins)
        contentView.flex.layout(mode: .adjustHeight)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.frame = CGRect(origin: contentView.frame.origin, size: size)
        contentView.flex.layout(mode: .adjustHeight)
        return contentView.frame.size
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory else { return }
        let scaledMinHeight = UIFontMetrics(forTextStyle: .body).scaledValue(for: minHeight)
        contentView.flex.minHeight(scaledMinHeight)
    }

    func set(title: String) {
        titleLabel.text = title
        titleLabel.flex.markDirty()
    }

    // MARK: - Private

    private let titleLabel: UILabel = {
        let l = UILabel()
        let theme =  AppEnvironment.current.theme
        l.textColor = theme.textColor
        l.backgroundColor = theme.ligherDarkColor
        l.highlightedTextColor = theme.darkColor
        l.numberOfLines = 0
        l.font = UIFont.preferredFont(forTextStyle: .body)
        l.adjustsFontForContentSizeCategory = true
        return l
    }()

    private let minHeight: CGFloat = 44
}
