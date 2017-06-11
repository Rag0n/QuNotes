//
// Created by Alexander Guschin on 11.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation

class Note {
    let createdDate: Double
    private(set) var updatedDate: Double
    private var tags = Set<String>()

    init() {
        self.createdDate = Date().timeIntervalSince1970
        self.updatedDate = self.createdDate
    }

    func allTags() -> [String] {
        return Array(self.tags)
    }
    
    func addTag(_ tag: String) {
        self.tags.insert(tag)
    }
}
