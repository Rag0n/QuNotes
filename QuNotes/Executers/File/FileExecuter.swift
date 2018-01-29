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
        return url.documentsBase |> (content |> dataFromContent |> writeData)
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
        return Result(try contentOfFolder(at: URL.documentsURL()))
    }

    public func readFile<T: Decodable>(at url: URL, contentType: T.Type) -> Result<T, AnyError> {
        do {
            let data = try Data(contentsOf: url)
            let content = try decoder.decode(contentType, from: data)
            return Result.success(content)
        } catch {
            return Result.failure(AnyError(error))
        }
    }

    public func readFile<T: Decodable>(at url: DynamicBaseURL, contentType: T.Type) -> Result<T, AnyError> {
        return readFile(at: url.documentsBase, contentType: contentType)
    }

    // MARK: - Private

    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()

    private func dataFromContent<T: Encodable>(_ content: T) -> Result<Data, AnyError> {
        return Result(try encoder.encode(content))
    }

    private func writeData(data result: Result<Data, AnyError>) -> (URL) -> Error? {
        return { url in
            guard let data = result.value else { return result.error?.error }
            do {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                try data.write(to: url)
                return nil
            } catch {
                return error
            }
        }
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
            try FileManager.default.removeItem(at: url.appendedToDocumentsURL())
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
}

private extension DynamicBaseURL {
    var documentsBase: URL {
        return url.appendedToDocumentsURL()
    }
}
