//
//  FileNotebookRepository.swift
//  QuNotes
//
//  Created by Alexander Guschin on 02.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

enum FileNotebookRepositoryError: Error {
    case failedToFindDocumentDirectory
    case failedToCreateFile
}

class FileNotebookRepository: NotebookRepository {
    // MARK: - API

    var fileManager: FileManager!
    var fileReader: FileReaderService!

    func getAll() -> Result<[Notebook], AnyError> {
        return Result(try notebooksFromNotebookFiles())
    }

    func save(notebook: Notebook) -> Result<Notebook, AnyError> {
        return .success(notebook)
    }

    func delete(notebook: Notebook) -> Result<Notebook, AnyError> {
        return .success(notebook)
    }

    // MARK: - Private

    private lazy var encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.outputFormatting = .prettyPrinted
        return enc
    }()
    private lazy var decoder = JSONDecoder()

    private func notebooksFromNotebookFiles() throws -> [Notebook] {
        return try notebookFiles().map(notebookFromFile)
    }

    private func notebookFiles() throws -> [URL] {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileNotebookRepositoryError.failedToFindDocumentDirectory
        }
        let documentDirectoryContent = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
        return documentDirectoryContent.filter { $0.pathExtension == "qvnotebook" }
    }

    private func notebookFromFile(fileURL: URL) throws -> Notebook {
        let data = try fileReader.dataFrom(fileURL: fileURL)
        return try decoder.decode(Notebook.self, from: data)
    }
}
