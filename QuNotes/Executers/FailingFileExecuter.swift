//
//  FailingFileExecuter.swift
//  QuNotes
//
//  Created by Alexander Guschin on 18.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

class FailingFileExecuter: FileExecuter {
    // MARK: - API

    override func createFile<T: Encodable>(atURL url: URL, content: T) -> Error? {
        return error
    }

    override func deleteDirectory(at url: URL) -> Error? {
        return error
    }

    override func deleteFile(at url: URL) -> Error? {
        return error
    }

    override func contentOfFolder(at url: URL) -> Result<[URL], NSError> {
        return Result(error: error)
    }

    override func contentOfDocumentsFolder() -> Result<[URL], NSError>  {
        return Result(error: error)
    }

    override func readFile<T: Decodable>(at url: URL, contentType: T.Type) -> Result<T, AnyError> {
        return Result(error: AnyError(error))
    }

    // MARL: - Private

    let error = NSError(domain: "Error domain", code: 123,
                        userInfo: [NSLocalizedDescriptionKey: "message"])
}
