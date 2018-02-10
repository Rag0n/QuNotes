//
//  FileExecuter.swift
//  QuNotes
//
//  Created by Alexander Guschin on 10.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result
import Prelude
import Core

public struct FileExecuter: FileExecuterType {
    public init() {
        encoder.outputFormatting = .prettyPrinted
    }

    public func createFile<T: Encodable>(atURL url: DynamicBaseURL, content: T) -> Error? {
        do {
            try writeContentToFile(at: url.documentsBase, content: content)
            return nil
        } catch {
            return error
        }
    }

    public func deleteDirectory(at url: DynamicBaseURL) -> Error? {
        return url |> removeItem
    }

    public func deleteFile(at url: DynamicBaseURL) -> Error? {
        return url |> removeItem
    }

    public func contentOfFolder(at url: DynamicBaseURL) -> Result<[URL], AnyError> {
        return Result(try contentOfFolder(at: url.documentsBase))
    }

    public func contentOfDocumentsFolder() -> Result<[URL], AnyError>  {
        return Result(try contentOfFolder(at: URL.documentsURL))
    }

    public func readFile<T: Decodable>(at url: DynamicBaseURL, contentType: T.Type) -> Result<T, AnyError> {
        return readFile(at: url.documentsBase, contentType: contentType)
    }

    public func readFile<T: Decodable>(at url: URL, contentType: T.Type) -> Result<T, AnyError> {
        return Result(try readAndDecodeFile(at: url, contentType: contentType))
    }

    // MARK: - Private

    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()

    private func writeContentToFile<T: Encodable>(at url: URL, content: T) throws {
        let data = try encoder.encode(content)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try data.write(to: url)
    }

    private func removeItem(at url: DynamicBaseURL) -> Error? {
        do {
            try FileManager.default.removeItem(at: url.documentsBase)
            return nil
        } catch {
            return error
        }
    }

    private func removeItem(at url: URL) -> Error? {
        do {
            try FileManager.default.removeItem(at: url.appendedToDocumentsURL)
            return nil
        } catch {
            return error
        }
    }

    private func contentOfFolder(at url: URL) throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: url,
                                                           includingPropertiesForKeys: nil,
                                                           options: [])
    }

    private func readAndDecodeFile<T: Decodable>(at url: URL, contentType: T.Type) throws -> T {
        let data = try Data(contentsOf: url)
        return try decoder.decode(contentType, from: data)
    }
}

private extension DynamicBaseURL {
    var documentsBase: URL {
        return url.appendedToDocumentsURL
    }
}
