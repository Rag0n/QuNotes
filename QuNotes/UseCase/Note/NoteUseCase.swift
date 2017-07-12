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
                           uuid: UUID.init().uuidString,
                           tags: [])
        noteRepository.save(note: newNote)

        return newNote
    }

    func getAllNotes() -> [Note] {
        return noteRepository.getAll()
    }

    func updateNote(_ note: Note, newContent: String) -> Note? {
        return updateNoteIfPossible(note, updatedNote: updatedNote(withOldNote: note, content: newContent))
    }

    func updateNote(_ note: Note, newTitle: String) -> Note? {
        return updateNoteIfPossible(note, updatedNote: updatedNote(withOldNote: note, title: newTitle))
    }

    func addTag(tag: String, toNote note: Note) -> Note? {
        return updateNoteIfPossible(note, updatedNote: updatedNote(withOldNote: note, tags: note.tags + [tag]))
    }

    func removeTag(tag: String, fromNote note: Note) -> Note? {
        var newTags = note.tags
        newTags.remove(object: tag)
        if newTags.count == note.tags.count {
            return note
        } else {
            return updateNoteIfPossible(note, updatedNote: updatedNote(withOldNote: note, tags: newTags))
        }
    }

    func deleteNote(_ note: Note) {
        noteRepository.delete(note: note)
    }

    private func updateNoteIfPossible(_ note: Note, updatedNote: @autoclosure () -> Note) -> Note? {
        let noteInRepository = noteRepository.get(noteId: note.uuid)
        guard noteInRepository.value != nil else {
            return nil;
        }

        let newNote = updatedNote()
        noteRepository.save(note: newNote)

        return newNote
    }

    private func updatedNote(withOldNote note: Note, title: String? = nil, content: String? = nil, tags: [String]? = nil) -> Note {
        return Note(createdDate: note.createdDate,
                    updatedDate: currentDateService.currentDate().timeIntervalSince1970,
                    content: content ?? note.content,
                    title: title ?? note.title,
                    uuid: note.uuid,
                    tags: tags ?? note.tags)
    }
}
