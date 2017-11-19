//
//  FailingFileExecuter.swift
//  QuNotes
//
//  Created by Alexander Guschin on 18.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

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

    // MARL: - Private

    let error = NSError(domain: "Error domain", code: 123,
                        userInfo: [NSLocalizedDescriptionKey: "message"])
}
