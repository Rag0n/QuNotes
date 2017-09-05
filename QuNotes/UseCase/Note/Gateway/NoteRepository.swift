//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Result

protocol NoteRepository {
    func getAll() -> Result<[Note], AnyError>
    func get(noteId: String) -> Result<Note, AnyError>
    func save(note: Note) -> Result<Note, AnyError>
    func delete(note: Note) -> Result<Note, AnyError>
}
