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
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentsDirectoryPath = NSURL(string: documentsPath)!
            let jsonFilePath = documentsDirectoryPath.appendingPathComponent("\(note.uuid).qvnote")!

            var isDirectory: ObjCBool = false
            if !fileManager.fileExists(atPath: jsonFilePath.absoluteString, isDirectory: &isDirectory) {
                let created = fileManager.createFile(atPath: jsonFilePath.absoluteString, contents: nil, attributes: nil)
                if !created {
                    // TODO: error handling
                }
            }

            let file = try FileHandle(forWritingTo: jsonFilePath)
            let jsonData = try encoder.encode(note)
            file.write(jsonData)
            print("JSON data was written to teh file successfully!")
        } catch let error as NSError {
            // TODO: implement error handling
            print(error)
        }
    }

    func delete(note: Note) {
    }
}

