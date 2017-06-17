//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

protocol NoteRepository {
    func getAll() -> [Note]
    func save(note: Note)
    func delete(note: Note)
}