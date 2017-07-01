//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation

protocol HasNoteUseCase {
    var noteUseCase: NoteUseCase { get }
}

class NoteUseCase {
    let noteRepository: NoteRepository

    init(withNoteReposiroty noteRepository: NoteRepository) {
        self.noteRepository = noteRepository
    }

    func addNote(withContent content: String) -> Note {
        let newNote = Note(content: content)
        noteRepository.save(note: newNote)

        return newNote
    }

    func getAllNotes() -> [Note] {
        return noteRepository.getAll()
    }

    func updateNote(_ note: Note, newContent: String) -> Note? {
        let noteInRepository = noteRepository.get(noteId: note.uuid)
        guard noteInRepository.value != nil else {
            return nil;
        }

        noteRepository.delete(note: note)
        let updatedNote =  Note(content: newContent)
        noteRepository.save(note: updatedNote)

        return updatedNote

    }
}

