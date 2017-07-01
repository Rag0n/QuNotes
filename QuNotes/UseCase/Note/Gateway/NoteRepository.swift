//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Result

enum NoteRepositoryError: Error {
    case notFound
}

protocol NoteRepository {
    func getAll() -> [Note]
    func get(noteId: String) -> Result<Note, NoteRepositoryError>
    func save(note: Note)
    func delete(note: Note)
}
