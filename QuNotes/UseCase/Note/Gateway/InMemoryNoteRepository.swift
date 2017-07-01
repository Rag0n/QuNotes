//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Result

class InMemoryNoteRepository: NoteRepository {
    private var notes = [Note]()

    func getAll() -> [Note] {
        return notes
    }

    func get(noteId: String) -> Result<Note, NoteRepositoryError> {
        let notesWithPassedId = notes.filter { note in note.uuid == noteId }
        if let foundNote = notesWithPassedId.first {
            return Result.success(foundNote)
        } else {
            return Result.failure(NoteRepositoryError.notFound)
        }
    }

    func save(note: Note) {
        notes.append(note)
    }

    func delete(note: Note) {
        guard let indexOfRemovedNote = notes.index(of: note) else {
            return;
        }
        notes.remove(at: indexOfRemovedNote)
    }
}

