//
//  Notebook.swift
//  QuNotes
//
//  Created by Alexander Guschin on 10.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

enum NotebookError: Error {
    case noteIsNotExists
}

class Notebook {

    let uuid: String
    let name: String
    private var notes = [String]()

    init(name: String) {
        self.name = name
        self.uuid = UUID.init().uuidString
    }

    convenience init() {
        self.init(name: "")
    }

    func allNotes() -> [String] {
        return notes
    }

    func addNote(_ note: String) {
        notes.append(note)
    }

    func getNote(_ i: Int) -> Result<String, NotebookError> {
        if i >= notes.count {
            return .failure(.noteIsNotExists)
        } else {
            return .success(notes[i])
        }
    }
}

extension Notebook: Equatable {
    static func ==(lhs: Notebook, rhs: Notebook) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
