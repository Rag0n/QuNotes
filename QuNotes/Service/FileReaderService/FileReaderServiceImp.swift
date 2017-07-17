//
//  FileReaderServiceImp.swift
//  QuNotes
//
//  Created by Alexander Guschin on 15.07.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

struct FileReaderServiceImp: FileReaderService {
    func dataFrom(fileURL: URL) throws -> Data {
        return try Data(contentsOf: fileURL)
    }
}
