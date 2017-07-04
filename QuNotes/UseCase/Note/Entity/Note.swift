//
// Created by Alexander Guschin on 11.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation

struct Note: Codable {
    let createdDate: Double
    let updatedDate: Double
    let content: String
    let title: String
    let uuid: String
}

extension Note: Equatable {
    static func ==(lhs: Note, rhs: Note) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
