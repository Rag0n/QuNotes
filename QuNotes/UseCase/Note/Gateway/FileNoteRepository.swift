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

    init(withFileManager fileManager: FileManager) {
        self.fileManager = fileManager
        encoder.outputFormatting = .prettyPrinted
    }

    func getAll() -> [Note] {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // TODO: implement error handling
            return [];
        }
        do {
            let documentDirectoryContent = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            let qvnoteFiles = documentDirectoryContent.filter { $0.pathExtension == "qvnote" }

            return try qvnoteFiles.map { url in
                let data = try Data(contentsOf: url)
                return try decoder.decode(Note.self, from: data)
            }
        } catch {
            // TODO: implement error handling
            return []
        }
    }

    func get(noteId: String) -> Result<Note, NoteRepositoryError> {
        return Result.failure(NoteRepositoryError.notFound)
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
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            // TODO: implement error handling
            return;
        }

        let jsonFilePath = documentsURL.appendingPathComponent("\(note.uuid)").appendingPathExtension("qvnote")
        let jsonData = try encoder.encode(note)
        guard fileManager.createFile(atPath: jsonFilePath.path, contents: jsonData, attributes: nil) else {
            // TODO: implement error handling
            return;
        }
    }

    func delete(note: Note) {
    }
}

