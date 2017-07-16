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

    func getAll() -> [Note] {
        do {
            return try mapNoteFilesToNotes()
        } catch {
            // TODO: implement error handling
            return []
        }
    }

    private func mapNoteFilesToNotes() throws -> [Note] {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // TODO: implement error handling
            return [];
        }

        let documentDirectoryContent = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
        let noteFiles = documentDirectoryContent.filter { $0.pathExtension == "qvnote" }

        return try noteFiles.map { url in
            let data = try self.fileReader.dataFromFile(fileURL: url)
            return try decoder.decode(Note.self, from: data)
        }
    }

    func get(noteId: String) -> Result<Note, NoteRepositoryError> {
        do {
            return try noteFromFile(withNoteUUID: noteId)
        } catch {
            return Result.failure(NoteRepositoryError.notFound)
        }
    }

    private func noteFromFile(withNoteUUID noteUUID: String) throws -> Result<Note, NoteRepositoryError>  {
        guard let noteFileURL = getNoteURLFromNoteId(noteId: noteUUID) else {
            // TODO: implement error handling
            return Result.failure(NoteRepositoryError.notFound)
        }

        let noteData = try self.fileReader.dataFromFile(fileURL: noteFileURL)
        let note = try decoder.decode(Note.self, from: noteData)

        return Result.success(note)

    }

    func save(note: Note) {
        do {
            try saveNoteToFile(note)
        } catch let error as NSError {
            // TODO: implement error handling
            print(error)
        }
    }

    private func saveNoteToFile(_ note: Note) throws {
        guard let noteFileURL = getNoteURLFromNoteId(noteId: note.uuid) else {
            // TODO: implement error handling
            return;
        }
        let jsonData = try encoder.encode(note)
        guard fileManager.createFile(atPath: noteFileURL.path, contents: jsonData, attributes: nil) else {
            // TODO: implement error handling
            return;
        }
    }

    func delete(note: Note) {
        do {
            try deleteFileWithNoteUUID(noteUUID: note.uuid)
        } catch {
            // TODO: implement error handling
        }
    }

    private func deleteFileWithNoteUUID(noteUUID: String) throws {
        guard let noteFileURL = getNoteURLFromNoteId(noteId: noteUUID) else {
            // TODO: implement error handling
            return;
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

