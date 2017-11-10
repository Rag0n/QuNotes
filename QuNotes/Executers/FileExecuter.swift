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
        let writeContent = writeToURL <| url.appendedToDocumentsURL()
        return writeContent <| dataFromContent <| content
    }

    func deleteFile(atURL url: URL) {

    }

    // MARK: - Private

    private lazy var encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.outputFormatting = .prettyPrinted
        return enc
    }()

    private func dataFromContent<T: Encodable>(_ content: T) -> Result<Data, AnyError> {
        return Result(try encoder.encode(content))
    }

    private func writeToURL(_ url: URL) -> (Result<Data, AnyError>) -> Error? {
        return { result in
            guard let data = result.value else { return result.error?.error }
            do {
                try data.write(to: url)
                return nil
            } catch {
                return error
            }
        }
    }
}
