//
//  FileReaderService.swift
//  QuNotes
//
//  Created by Alexander Guschin on 15.07.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

protocol FileReaderService {
    func dataFromFile(fileURL: URL) -> Result<Data, AnyError>
}
