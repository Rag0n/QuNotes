//
//  Array+Extensions.swift
//  QuNotes
//
//  Created by Alexander Guschin on 12.07.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

extension Array where Element: Equatable {
    func appending(_ newElement: Element) -> [Element] {
        var updatedArray = self
        updatedArray.append(newElement)
        return updatedArray
    }

    func removing(_ element: Element) -> [Element] {
        guard let index = index(of: element) else { return self }
        var updatedArray = self
        updatedArray.remove(at: index)
        return updatedArray
    }

    func removing(at index: Int) -> [Element] {
        var updatedArray = self
        updatedArray.remove(at: index)
        return updatedArray
    }

    func replacing(at index: Int, new element: Element) -> [Element] {
        var updatedArray = self
        updatedArray[index] = element
        return updatedArray
    }
}
