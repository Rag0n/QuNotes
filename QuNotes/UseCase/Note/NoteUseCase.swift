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
    let currentDateService: CurrentDateService

    init(withNoteReposiroty noteRepository: NoteRepository, currentDateService: CurrentDateService) {
        self.noteRepository = noteRepository
        self.currentDateService = currentDateService
    }

    func addNote(withTitle title: String) -> Note {
        let currentTimestamp = currentDateService.currentDate().timeIntervalSince1970
        let newNote = Note(createdDate: currentTimestamp,
                           updatedDate: currentTimestamp,
                           content: "",
                           title: title,
                           uuid: UUID.init().uuidString)
        noteRepository.save(note: newNote)
        
        return newNote
    }

    func addNote(withContent content: String) -> Note {
        let newNote = Note(createdDate: 0, updatedDate: 0, content: content, title: "title", uuid: "uuid")
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
        let updatedNote = Note(createdDate: 0, updatedDate: 0, content: newContent, title: "title", uuid: "uuid")
        noteRepository.save(note: updatedNote)

        return updatedNote

    }
}

