//
//  FailingFileExecuter.swift
//  QuNotes
//
//  Created by Alexander Guschin on 18.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result
import Core

// TODO: Create template for sourcery and replace it by generated file
struct FailingFileExecuter: FileExecuterType {
    func createFile<T: Encodable>(atURL url: DynamicBaseURL, content: T) -> Error? {
        return error
    }

    func deleteDirectory(at url: DynamicBaseURL) -> Error? {
        return error
    }

    func deleteFile(at url: DynamicBaseURL) -> Error? {
        return error
    }

    func contentOfFolder(at url: DynamicBaseURL) -> Result<[URL], AnyError> {
        return Result(error: anyError)
    }

    func contentOfDocumentsFolder() -> Result<[URL], AnyError>  {
        return Result(error: anyError)
    }

    func readFile<T: Decodable>(at url: URL, contentType: T.Type) -> Result<T, AnyError> {
        return Result(error: anyError)
    }

    func readFile<T: Decodable>(at url: DynamicBaseURL, contentType: T.Type) -> Result<T, AnyError> {
        return Result(error: anyError)
    }

    // MARL: - Private

    private let error = NSError(domain: "Error domain", code: 123,
                                userInfo: [NSLocalizedDescriptionKey: "message"])
    private var anyError: AnyError {
        return AnyError(error)
    }
}
