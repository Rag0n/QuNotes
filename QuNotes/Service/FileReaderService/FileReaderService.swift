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
    func dataFrom(fileURL: URL) throws -> Data
}
