//
//  DynamicBaseURL.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

/// Phantom-like URL struct for urls with unknown for core base.
/// Most likely base is documents folder.
/// Purpose of this type is to create virtual URLs with unknown, but same base.
/// Base will be determined later at some point.
public struct DynamicBaseURL: AutoEquatable, AutoLens {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }
}
