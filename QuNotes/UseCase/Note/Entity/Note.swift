//
// Created by Alexander Guschin on 11.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation

struct Note {
    let createdDate: Double
    let content: String
    fileprivate let uuid: String

    init(content: String) {
        self.content = content
        self.createdDate = Date().timeIntervalSince1970
        self.uuid = UUID.init().uuidString
    }
}

extension Note: Equatable {
    static func ==(lhs: Note, rhs: Note) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
