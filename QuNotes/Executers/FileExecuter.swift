//
//  FileExecuter.swift
//  QuNotes
//
//  Created by Alexander Guschin on 10.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

protocol HasFileExecuter {
    var fileExecuter: FileExecuter { get }
}

class FileExecuter {
    // MARK: - API

    func createFile<T: Encodable>(atURL url: URL, content: T) -> Error? {
        let writeData = writeToURL <| url.appendedToDocumentsURL()
        return writeData <| dataFromContent <| content
    }

    func deleteDirectory(at url: URL) -> Error? {
        return removeItemAtURL <| url
    }

    func deleteFile(at url: URL) -> Error? {
        return removeItemAtURL <| url
    }

    func contentOfDocumentsFolder() -> Result<[URL], AnyError>  {
        return Result(try contentOfDocumentsFolder())
    }

    // MARK: - Private

    fileprivate lazy var encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.outputFormatting = .prettyPrinted
        return enc
    }()
}

fileprivate extension FileExecuter {
    func dataFromContent<T: Encodable>(_ content: T) -> Result<Data, AnyError> {
        return Result(try encoder.encode(content))
    }

    func writeToURL(_ url: URL) -> (Result<Data, AnyError>) -> Error? {
        return { result in
            guard let data = result.value else { return result.error?.error }
            do {
                try FileManager.default.createDirectory(atPath: url.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
                try data.write(to: url)
                return nil
            } catch {
                return error
            }
        }
    }

    func removeItemAtURL(_ url: URL) -> Error? {
        do {
            try FileManager.default.removeItem(at: url.appendedToDocumentsURL())
            return nil
        }
        catch {
            return error
        }
    }

    func contentOfDocumentsFolder() throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: URL.documentsURL(),
                                                           includingPropertiesForKeys: nil,
                                                           options: [])
    }
}
