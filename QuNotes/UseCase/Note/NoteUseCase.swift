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

    func addNote(withContent content: String) -> Note {
        let newNote = Note(content: content)
        notes.append(newNote)

        return newNote
    }

    func getAllNotes() -> [Note] {
        return notes
    }

    func updateNote(_ note: Note, newContent: String) -> Note? {
        guard let indexOfRemovedNote = notes.index(of: note) else {
            return nil;
        }
        notes.remove(at: indexOfRemovedNote)
        let updatedNote = Note(content: newContent)
        notes.append(updatedNote)

        return updatedNote

    }
}

