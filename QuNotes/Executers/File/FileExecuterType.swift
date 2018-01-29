//
//  FileExecuterType.swift
//  QuNotes
//
//  Created by Alexander Guschin on 19.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result
import Core

public protocol FileExecuterType {
    func createFile<T: Encodable>(atURL url: DynamicBaseURL, content: T) -> Error?
    func deleteDirectory(at url: DynamicBaseURL) -> Error?
    func deleteFile(at url: DynamicBaseURL) -> Error?
    func contentOfFolder(at url: DynamicBaseURL) -> Result<[URL], AnyError>
    func contentOfDocumentsFolder() -> Result<[URL], AnyError>
    func readFile<T: Decodable>(at url: URL, contentType: T.Type) -> Result<T, AnyError>
    func readFile<T: Decodable>(at url: DynamicBaseURL, contentType: T.Type) -> Result<T, AnyError>
}
