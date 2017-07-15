//
//  FileReaderServiceImp.swift
//  QuNotes
//
//  Created by Alexander Guschin on 15.07.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

struct FileReaderServiceImp: FileReaderService {
    func dataFromFile(fileURL: URL) -> Result<Data, AnyError> {
        do {
            let data = try Data(contentsOf: fileURL)
            return Result.success(data)
        } catch {
            return Result.failure(AnyError(error))
        }
    }
}
