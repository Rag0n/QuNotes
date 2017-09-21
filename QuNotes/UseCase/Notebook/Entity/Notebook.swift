//
//  Notebook.swift
//  QuNotes
//
//  Created by Alexander Guschin on 10.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

struct Notebook: Codable {
    let uuid: String
    let name: String
}

extension Notebook: Equatable {
    static func ==(lhs: Notebook, rhs: Notebook) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
