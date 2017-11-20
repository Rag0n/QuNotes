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
    // MARK: - API

    var repository: NoteRepository!
    var currentDateService: CurrentDateService!

    func add(withTitle title: String) -> Result<UseCase.Note, AnyError> {
        return repository.save <| newNoteWithTitle <| title
    }

    func getAll() -> [UseCase.Note] {
        return repository.getAll().recover([])
    }

    func update(_ note: UseCase.Note, newContent: String) -> Result<UseCase.Note, AnyError> {
        return repository.save <| updatedNote(withNewContent: newContent) <| note
    }

    func update(_ note: UseCase.Note, newTitle: String) -> Result<UseCase.Note, AnyError> {
        return repository.save <| updatedNote(withNewTitle: newTitle) <| note
    }

    func addTag(tag: String, toNote note: UseCase.Note) -> Result<UseCase.Note, AnyError> {
        return repository.save <| updatedNote(withNewTags: note.tags + [tag]) <| note
    }

    func removeTag(tag: String, fromNote note: UseCase.Note) -> Result<UseCase.Note, AnyError> {
        let (tagsWereUpdated, tags) = updatedTagsWith(removedTag: tag, forNote: note)
        if (!tagsWereUpdated) { return .success(note) }
        return repository.save <| updatedNote(withNewTags: tags) <| note
    }

    func delete(_ note: UseCase.Note) -> Result<UseCase.Note, AnyError> {
        return repository.delete(note: note)
    }

    // MARK - Private

    private func newNoteWithTitle(title: String) -> UseCase.Note {
        let currentTimestamp = currentDateService.date().timeIntervalSince1970
        return UseCase.Note(createdDate: currentTimestamp,
                    updatedDate: currentTimestamp,
                    content: "",
                    title: title,
                    uuid: UUID.init().uuidString,
                    tags: [])
    }

    private func updatedNote(withNewTitle newTitle: String? = nil, withNewContent newContent: String? = nil, withNewTags newTags: [String]? = nil) -> (UseCase.Note) -> UseCase.Note {
        return { note in
            return UseCase.Note(createdDate: note.createdDate,
                        updatedDate: self.currentDateService.date().timeIntervalSince1970,
                        content: newContent ?? note.content,
                        title: newTitle ?? note.title,
                        uuid: note.uuid,
                        tags: newTags ?? note.tags)
        }
    }

    private func updatedTagsWith(removedTag: String, forNote note: UseCase.Note) -> (Bool, [String]) {
        var tags = note.tags
        if let removedTagIndex = tags.index(of: removedTag) {
            tags.remove(at: removedTagIndex)
            return (true, tags)
        } else {
            return (false, tags)
        }
    }
}
