//
//  Array+Extensions.swift
//  QuNotes
//
//  Created by Alexander Guschin on 12.07.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
