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
        return Result(try saveNotebookToFile(notebook))
    }

    func delete(notebook: Notebook) -> Result<Notebook, AnyError> {
        return .success(notebook)
    }

    // MARK: - Private

    fileprivate enum Constants {
        static let notebookFileExtension = "qvnotebook"
        static let notebookMetaFileName = "meta"
        static let notebookMetaFileExtension = "json"
    }

    private lazy var encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.outputFormatting = .prettyPrinted
        return enc
    }()
    private lazy var decoder = JSONDecoder()

    private func notebooksFromNotebookFiles() throws -> [Notebook] {
        return try notebookFiles().map(notebookMetaFile).map(notebookFromMetaFile)
    }

    private func notebookFiles() throws -> [URL] {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileNotebookRepositoryError.failedToFindDocumentDirectory
        }
        let documentDirectoryContent = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
        return documentDirectoryContent.filter { $0.pathExtension == Constants.notebookFileExtension }
    }

    private func notebookMetaFile(notebookURL: URL) throws -> URL {
        return notebookURL
            .appendingPathComponent(Constants.notebookMetaFileName, isDirectory: false)
            .appendingPathExtension(Constants.notebookMetaFileExtension)
    }

    private func notebookFromMetaFile(metaURL: URL) throws -> Notebook {
        let data = try fileReader.dataFrom(fileURL: metaURL)
        return try decoder.decode(Notebook.self, from: data)
    }

    private func saveNotebookToFile(_ notebook: Notebook) throws -> Notebook {
        let notebookDirectory = try notebookDirectoryURL(fromNotebookId: notebook.uuid)
        try fileManager.createDirectory(atPath: notebookDirectory.path, withIntermediateDirectories: false, attributes: nil)
        let notebookMetaFileURL = try notebookMetaFile(notebookURL: notebookDirectory)
        let jsonData = try encoder.encode(notebook)
        guard fileManager.createFile(atPath: notebookMetaFileURL.path, contents: jsonData, attributes: nil) else {
            throw FileNotebookRepositoryError.failedToCreateFile
        }
        return notebook
    }

    private func notebookDirectoryURL(fromNotebookId notebookId: String) throws -> URL {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileNotebookRepositoryError.failedToFindDocumentDirectory
        }
        return documentsURL
            .appendingPathComponent("\(notebookId)", isDirectory: true)
            .appendingPathExtension(Constants.notebookFileExtension)
    }
}
