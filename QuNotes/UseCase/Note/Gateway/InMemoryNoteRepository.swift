//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

class InMemoryNoteRepository: NoteRepository {
    private var notes = [Note]()

    func getAll() -> [Note] {
        return notes
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

