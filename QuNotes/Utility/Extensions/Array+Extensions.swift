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

    func removeWithoutMutation(at position: Int) -> [Element] {
        var updatedArray = self
        updatedArray.remove(at: position)
        return updatedArray
    }

    @available(*, deprecated)
    func removeWithoutMutation(object: Element) -> [Element] {
        var updatedArray = self
        updatedArray.remove(object: object)
        return updatedArray
    }

    func appending(_ newElement: Element) -> [Element] {
        var updatedArray = self
        updatedArray.append(newElement)
        return updatedArray
    }

    func removing(_ element: Element) -> [Element] {
        var updatedArray = self
        updatedArray.remove(object: element)
        return updatedArray
    }
}
