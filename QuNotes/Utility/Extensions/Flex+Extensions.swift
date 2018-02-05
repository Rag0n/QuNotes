//
//  Flex+Extensions.swift
//  QuNotes
//
//  Created by Alexander Guschin on 05.02.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import UIKit
import FlexLayout

extension UILabel {
    final func markDirtyAndSetText(_ text: String?) {
        self.text = text
        self.flex.markDirty()
    }
}
