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

    private var notes = [String]()

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
