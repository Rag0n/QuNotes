//
// Created by Alexander Guschin on 11.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation

extension UseCase {
    struct Note: Codable {
        let createdDate: Double
        let updatedDate: Double
        let content: String
        let title: String
        let uuid: String
        let tags: [String]
    }
}

extension UseCase.Note: Equatable {
    static func ==(lhs: UseCase.Note, rhs: UseCase.Note) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
