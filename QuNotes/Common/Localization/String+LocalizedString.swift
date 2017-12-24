//
//  String+LocalizedString.swift
//  QuNotes
//
//  Created by Alexander Guschin on 24.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

public extension String {
    /// Returns result of localizedString function with a key equal to self
    public var localized: String {
        return localizedString(key: self)
    }
}
