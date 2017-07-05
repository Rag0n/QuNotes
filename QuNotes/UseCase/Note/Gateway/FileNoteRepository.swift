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
        return []
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

    private func saveNoteToFile(note: Note) throws {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        guard let documentsDirectoryPath = NSURL(string: documentsPath) else {
            // TODO: implement error handling
            return;
        }
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("\(note.uuid).qvnote")!
        guard fileManager.createFile(atPath: jsonFilePath.absoluteString, contents: nil, attributes: nil) else {
            // TODO: implement error handling
            return;
        }

        let jsonData = try encoder.encode(note)
        let file = try FileHandle(forWritingTo: jsonFilePath)
        file.write(jsonData)
    }

    func delete(note: Note) {
    }
}

