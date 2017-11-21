//
//  Notebook.swift
//  QuNotes
//
//  Created by Alexander Guschin on 10.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

extension UseCase {
    struct Notebook: Codable {
        let uuid: String
        let name: String
    }
}

extension UseCase.Notebook: Equatable {
    static func ==(lhs: UseCase.Notebook, rhs: UseCase.Notebook) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
