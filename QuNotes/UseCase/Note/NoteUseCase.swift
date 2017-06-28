//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation

protocol HasNoteUseCase {
    var noteUseCase: NoteUseCase { get }
}

class NoteUseCase {
    private var notes = [Note]()

    func addNote(withContent content: String) {
        let newNote = Note(content: content)
        notes.append(newNote)
    }

    func getAllNotes() -> [Note] {
        return notes
    }
}