//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Result

protocol NoteRepository {
    func getAll() -> Result<[UseCase.Note], AnyError>
    func get(noteId: String) -> Result<UseCase.Note, AnyError>
    func save(note: UseCase.Note) -> Result<UseCase.Note, AnyError>
    func delete(note: UseCase.Note) -> Result<UseCase.Note, AnyError>
}
