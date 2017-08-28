//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

enum NoteUseCaseError: Error {
    case notFound
}

protocol HasNoteUseCase {
    var noteUseCase: NoteUseCase { get }
}

class NoteUseCase {
    private let noteRepository: NoteRepository
    private let currentDateService: CurrentDateService

    init(withNoteReposiroty noteRepository: NoteRepository, currentDateService: CurrentDateService) {
        self.noteRepository = noteRepository
        self.currentDateService = currentDateService
    }

    // MARK: - API

    func addNote(withTitle title: String) -> Note {
        let currentTimestamp = currentDateService.currentDate().timeIntervalSince1970
        let newNote = Note(createdDate: currentTimestamp,
                           updatedDate: currentTimestamp,
                           content: "",
                           title: title,
                           uuid: UUID.init().uuidString,
                           tags: [])
        return saveNote(note: newNote)
    }

    func getAllNotes() -> [Note] {
        return noteRepository.getAll()
    }

    func updateNote(_ note: Note, newContent: String) -> Result<Note, NoteUseCaseError> {
        return updateNote(note,
                          noteUpdater: updatedNote(withNewContent: newContent))
    }

    func updateNote(_ note: Note, newTitle: String) -> Result<Note, NoteUseCaseError> {
        return updateNote(note,
                          noteUpdater: updatedNote(withNewTitle: newTitle))
    }

    func addTag(tag: String, toNote note: Note) -> Result<Note, NoteUseCaseError> {
        return updateNote(note,
                          noteUpdater: updatedNote(withNewTags: note.tags + [tag]))
    }

    func removeTag(tag: String, fromNote note: Note) -> Result<Note, NoteUseCaseError> {
        return updateNote(note,
                          noteUpdater: updatedNote(withNewTags: newTagsForNote(note: note, removedTag: tag)))
    }

    func deleteNote(_ note: Note) {
        noteRepository.delete(note: note)
    }

    // MARK - Private

    private func updateNote(_ note: Note, noteUpdater: @escaping (_ oldNote: Note) -> Note) -> Result<Note, NoteUseCaseError> {
        return noteRepository
            .get(noteId: note.uuid)
            .map(updateNote(noteUpdater: noteUpdater))
            .map(saveNote)
    }

    private func updateNote(noteUpdater: @escaping (_ oldNote: Note) -> Note) -> (Note) -> Note {
        return { oldNote -> Note in
            return noteUpdater(oldNote)
        }
    }

    private func saveNote(note: Note) -> Note {
        noteRepository.save(note: note)
        return note
    }

    private func updatedNote(withNewTitle newTitle: String? = nil, withNewContent newContent: String? = nil, withNewTags newTags: [String]? = nil) -> (Note) -> Note {
        return { note in
            return Note(createdDate: note.createdDate,
                        updatedDate: self.currentDateService.currentDate().timeIntervalSince1970,
                        content: newContent ?? note.content,
                        title: newTitle ?? note.title,
                        uuid: note.uuid,
                        tags: newTags ?? note.tags)
        }
    }

    private func newTagsForNote(note: Note, removedTag: String) -> [String] {
        var newTags = note.tags
        newTags.remove(object: removedTag)
        return newTags
    }
}
