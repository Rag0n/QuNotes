//
//  FileExecuterType.swift
//  QuNotes
//
//  Created by Alexander Guschin on 19.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

public protocol FileExecuterType {
    func createFile<T: Encodable>(atURL url: URL, content: T) -> Error?
    func deleteDirectory(at url: URL) -> Error?
    func deleteFile(at url: URL) -> Error?
    func contentOfFolder(at url: URL) -> Result<[URL], NSError>
    func contentOfDocumentsFolder() -> Result<[URL], NSError>
    func readFile<T: Decodable>(at url: URL, contentType: T.Type) -> Result<T, AnyError>
}
