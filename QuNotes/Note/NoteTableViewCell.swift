//
//  NoteTableViewCell.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.01.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import UIKit
import FlexLayout
import Notepad

final class NoteTableViewCell: UITableViewCell {
    typealias OnContentChange = (String) -> ()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let backgroundColor = AppEnvironment.current.theme.ligherDarkColor
        self.backgroundColor = backgroundColor
        contentView.backgroundColor = backgroundColor
        contentView.flex.minHeight(scaledMinHeight).define {
            $0.addItem(editor).grow(1)
        }
        editor.delegate = self
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
        contentView.flex.padding(contentView.layoutMargins).maxHeight(maxHeight).layout(mode: .adjustHeight)
        return contentView.frame.size
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory else { return }
        contentView.flex.minHeight(scaledMinHeight)
    }

    func set(content: String, maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude, onContentChange: @escaping OnContentChange) {
        self.maxHeight = maxHeight
        self.onContentChange = onContentChange
        editor.text = content
        editor.flex.markDirty()
    }

    // MARK: - Private

    private enum Constants {
        static let minHeight: CGFloat = 44
        static let themeName = "one-dark"
    }

    private var maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude
    private var onContentChange: OnContentChange?

    private let editor: Notepad = {
        let n = Notepad(frame: CGRect.zero, themeFile: Constants.themeName)
        n.keyboardAppearance = .dark
        n.returnKeyType = .done
        return n
    }()
    private var scaledMinHeight: CGFloat {
        return UIFontMetrics(forTextStyle: .body).scaledValue(for: Constants.minHeight)
    }
}

// MARK: - UITextViewDelegate

extension NoteTableViewCell: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        onContentChange?(textView.text ?? "")
    }
}
