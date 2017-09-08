//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

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

    func add(withTitle title: String) -> Result<Note, AnyError> {
        return noteRepository.save <| newNoteWithTitle <| title
    }

    func getAll() -> [Note] {
        return noteRepository.getAll().recover([])
    }

    func update(_ note: Note, newContent: String) -> Result<Note, AnyError> {
        return noteRepository.save <| updatedNote(withNewContent: newContent) <| note
    }

    func update(_ note: Note, newTitle: String) -> Result<Note, AnyError> {
        return noteRepository.save <| updatedNote(withNewTitle: newTitle) <| note
    }

    func addTag(tag: String, toNote note: Note) -> Result<Note, AnyError> {
        return noteRepository.save <| updatedNote(withNewTags: note.tags + [tag]) <| note
    }

    func removeTag(tag: String, fromNote note: Note) -> Result<Note, AnyError> {
        let (tagsWereUpdated, tags) = updatedTagsWith(removedTag: tag, forNote: note)
        if (!tagsWereUpdated) { return .success(note) }
        return noteRepository.save <| updatedNote(withNewTags: tags) <| note
    }

    func delete(_ note: Note) -> Result<Note, AnyError> {
        return noteRepository.delete(note: note)
    }

    // MARK - Private

    private func newNoteWithTitle(title: String) -> Note {
        let currentTimestamp = currentDateService.currentDate().timeIntervalSince1970
        return Note(createdDate: currentTimestamp,
                    updatedDate: currentTimestamp,
                    content: "",
                    title: title,
                    uuid: UUID.init().uuidString,
                    tags: [])
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

    private func updatedTagsWith(removedTag: String, forNote note: Note) -> (Bool, [String]) {
        var tags = note.tags
        if let removedTagIndex = tags.index(of: removedTag) {
            tags.remove(at: removedTagIndex)
            return (true, tags)
        } else {
            return (false, tags)
        }
    }
}
