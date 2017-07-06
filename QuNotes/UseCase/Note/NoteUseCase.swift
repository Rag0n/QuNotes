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

    func getAllNotes() -> [Note] {
        return noteRepository.getAll()
    }

    func updateNote(_ note: Note, newContent: String) -> Note? {
        let noteInRepository = noteRepository.get(noteId: note.uuid)
        guard noteInRepository.value != nil else {
            return nil;
        }

        noteRepository.delete(note: note)
        let updatedNote = Note(createdDate: note.createdDate,
                               updatedDate: currentDateService.currentDate().timeIntervalSince1970,
                               content: newContent,
                               title: note.title,
                               uuid: note.uuid)
        noteRepository.save(note: updatedNote)

        return updatedNote

    }

    func updateNote(_ note: Note, newTitle: String) -> Note? {
        let noteInRepository = noteRepository.get(noteId: note.uuid)
        guard noteInRepository.value != nil else {
            return nil;
        }

        noteRepository.delete(note: note)
        let updatedNote = Note(createdDate: note.createdDate,
                               updatedDate: currentDateService.currentDate().timeIntervalSince1970,
                               content: note.content,
                               title: newTitle,
                               uuid: note.uuid)
        noteRepository.save(note: updatedNote)

        return updatedNote
    }

    func deleteNote(_ note: Note) {
        
    }
}

