//
//  FileNoteRepository.swift
//  QuNotes
//
//  Created by Alexander Guschin on 04.07.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

enum FileNoteRepositoryError: Error {
    case failedToFindDocumentDirectory
    case failedToCreateFile
}

class FileNoteRepository: NoteRepository {
    // MARK: - API

    var fileManager: FileManager!
    var fileReader: FileReaderService!

    func getAll() -> Result<[UseCase.Note], AnyError> {
        return Result(try mapNoteFilesToNotes())
    }

    func get(noteId: String) -> Result<UseCase.Note, AnyError> {
        return Result(try noteFromFile(withNoteUUID: noteId))
    }

    func save(note: UseCase.Note) -> Result<UseCase.Note, AnyError> {
        return Result(try saveNoteToFile(note))
    }

    func delete(note: UseCase.Note) -> Result<UseCase.Note, AnyError> {
        return Result(try deleteNote(note))
    }

    // MARK: - Private

    private lazy var encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.outputFormatting = .prettyPrinted
        return enc
    }()
    private lazy var decoder = JSONDecoder()

    private func mapNoteFilesToNotes() throws -> [UseCase.Note] {
        return try noteFiles().map(noteFromFile)
    }

    private func noteFiles() throws -> [URL] {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileNoteRepositoryError.failedToFindDocumentDirectory
        }
        let documentDirectoryContent = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
        return documentDirectoryContent.filter { $0.pathExtension == "qvnote" }
    }

    private func noteFromFile(fileURL: URL) throws -> UseCase.Note {
        let data = try fileReader.dataFrom(fileURL: fileURL)
        return try decoder.decode(UseCase.Note.self, from: data)
    }

    private func noteFromFile(withNoteUUID noteUUID: String) throws -> UseCase.Note  {
        let noteFileURL = try getNoteURLFromNoteId(noteId: noteUUID)
        return try noteFromFile(fileURL: noteFileURL)
    }

    private func getNoteURLFromNoteId(noteId: String) throws -> URL {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileNoteRepositoryError.failedToFindDocumentDirectory
        }
        return documentsURL.appendingPathComponent("\(noteId)").appendingPathExtension("qvnote")
    }

    private func saveNoteToFile(_ note: UseCase.Note) throws -> UseCase.Note {
        let noteFileURL = try getNoteURLFromNoteId(noteId: note.uuid)
        let jsonData = try encoder.encode(note)
        guard fileManager.createFile(atPath: noteFileURL.path, contents: jsonData, attributes: nil) else {
            throw FileNoteRepositoryError.failedToCreateFile
        }
        return note
    }

    private func deleteNote(_ note: UseCase.Note) throws -> UseCase.Note {
        try deleteFileWithNoteUUID(note.uuid)
        return note
    }

    private func deleteFileWithNoteUUID(_ noteUUID: String) throws {
        let noteFileURL = try getNoteURLFromNoteId(noteId: noteUUID)
        try fileManager.removeItem(at: noteFileURL)
    }
}
