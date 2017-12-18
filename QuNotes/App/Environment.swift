//
//  Environment.swift
//  QuNotes
//
//  Created by Alexander Guschin on 18.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

/// A collection of all singletons and global state that the app wants access to
public struct Environment {
    public let theme: Theme

    public init(theme: Theme = DefaultTheme()) {
        self.theme = theme
    }
}
