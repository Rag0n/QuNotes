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
    private lazy var encoder = JSONEncoder()
    private lazy var decoder = JSONDecoder()
    private var fileManager: FileManager
    private var fileReader: FileReaderService

    init(withFileManager fileManager: FileManager, fileReader: FileReaderService) {
        self.fileManager = fileManager
        self.fileReader = fileReader
        encoder.outputFormatting = .prettyPrinted
    }

    // MARK: - API

    func getAll() -> Result<[Note], AnyError> {
        return Result(try mapNoteFilesToNotes())
    }

    func get(noteId: String) -> Result<Note, AnyError> {
        return Result(try noteFromFile(withNoteUUID: noteId))
    }

    func save(note: Note) -> Result<Note, AnyError> {
        return Result(try saveNoteToFile(note))
    }

    func delete(note: Note) -> Result<Note, AnyError> {
        return Result(try deleteNote(note))
    }

    // MARK: - Private

    private func mapNoteFilesToNotes() throws -> [Note] {
        return try noteFiles().map(noteFromFile)
    }

    private func noteFiles() throws -> [URL] {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return [];
        }
        let documentDirectoryContent = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
        return documentDirectoryContent.filter { $0.pathExtension == "qvnote" }
    }

    private func noteFromFile(fileURL: URL) throws -> Note {
        let data = try fileReader.dataFrom(fileURL: fileURL)
        return try decoder.decode(Note.self, from: data)
    }

    private func noteFromFile(withNoteUUID noteUUID: String) throws -> Note  {
        guard let noteFileURL = getNoteURLFromNoteId(noteId: noteUUID) else {
            throw NoteUseCaseError.notFound
        }
        let noteData = try self.fileReader.dataFrom(fileURL: noteFileURL)
        return try decoder.decode(Note.self, from: noteData)
    }

    private func getNoteURLFromNoteId(noteId: String) -> URL? {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil;
        }
        return documentsURL.appendingPathComponent("\(noteId)").appendingPathExtension("qvnote");
    }

    private func saveNoteToFile(_ note: Note) throws -> Note {
        guard let noteFileURL = getNoteURLFromNoteId(noteId: note.uuid) else {
            throw NoteUseCaseError.savingError
        }
        let jsonData = try encoder.encode(note)
        guard fileManager.createFile(atPath: noteFileURL.path, contents: jsonData, attributes: nil) else {
            throw NoteUseCaseError.savingError
        }
        return note
    }

    private func deleteNote(_ note: Note) throws -> Note {
        try deleteFileWithNoteUUID(note.uuid)
        return note
    }

    private func deleteFileWithNoteUUID(_ noteUUID: String) throws {
        guard let noteFileURL = getNoteURLFromNoteId(noteId: noteUUID) else {
            throw NoteUseCaseError.savingError
        }
        try fileManager.removeItem(at: noteFileURL)
    }
}
