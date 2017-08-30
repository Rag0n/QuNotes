//
//  FileNoteRepository.swift
//  QuNotes
//
//  Created by Alexander Guschin on 04.07.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

class FileNoteRepository: NoteRepository {
    private var encoder: JSONEncoder = JSONEncoder()
    private var decoder: JSONDecoder = JSONDecoder()
    private var fileManager: FileManager
    private var fileReader: FileReaderService

    init(withFileManager fileManager: FileManager, fileReader: FileReaderService) {
        self.fileManager = fileManager
        self.fileReader = fileReader
        encoder.outputFormatting = .prettyPrinted
    }

    func getAll() -> Result<[Note], NoteUseCaseError> {
        do {
            return try .success(mapNoteFilesToNotes())
        } catch {
            return .failure(NoteUseCaseError.brokenFormat)
        }
    }

    private func mapNoteFilesToNotes() throws -> [Note] {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return [];
        }
        let documentDirectoryContent = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
        let noteFiles = documentDirectoryContent.filter { $0.pathExtension == "qvnote" }

        return try noteFiles.map { url in
            let data = try self.fileReader.dataFrom(fileURL: url)
            return try decoder.decode(Note.self, from: data)
        }
    }

    func get(noteId: String) -> Result<Note, NoteUseCaseError> {
        do {
            return try noteFromFile(withNoteUUID: noteId)
        } catch {
            return Result.failure(NoteUseCaseError.notFound)
        }
    }

    private func noteFromFile(withNoteUUID noteUUID: String) throws -> Result<Note, NoteUseCaseError>  {
        guard let noteFileURL = getNoteURLFromNoteId(noteId: noteUUID) else {
            return Result.failure(NoteUseCaseError.notFound)
        }

        let noteData = try self.fileReader.dataFrom(fileURL: noteFileURL)
        let note = try decoder.decode(Note.self, from: noteData)

        return Result.success(note)
    }

    func save(note: Note) -> Result<Note, NoteUseCaseError> {
        do {
            try saveNoteToFile(note)
            return .success(note);
        } catch {
            return .failure(NoteUseCaseError.savingError)
        }
    }

    private func saveNoteToFile(_ note: Note) throws {
        guard let noteFileURL = getNoteURLFromNoteId(noteId: note.uuid) else {
            throw NoteUseCaseError.savingError
        }
        let jsonData = try encoder.encode(note)
        guard fileManager.createFile(atPath: noteFileURL.path, contents: jsonData, attributes: nil) else {
            throw NoteUseCaseError.savingError
        }
    }

    func delete(note: Note) -> Result<Note, NoteUseCaseError> {
        do {
            try deleteFileWithNoteUUID(noteUUID: note.uuid)
            return .success(note)
        } catch {
            return .failure(NoteUseCaseError.savingError)
        }
    }

    private func deleteFileWithNoteUUID(noteUUID: String) throws {
        guard let noteFileURL = getNoteURLFromNoteId(noteId: noteUUID) else {
            throw NoteUseCaseError.savingError
        }
        try fileManager.removeItem(at: noteFileURL)
    }

    private func getNoteURLFromNoteId(noteId: String) -> URL? {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil;
        }
        return documentsURL.appendingPathComponent("\(noteId)").appendingPathExtension("qvnote");
    }
}

