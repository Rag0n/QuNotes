//
//  FileNotebookRepositorySpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 02.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

// MARK: - FileNoteRepositorySpec

class FileNotebookRepositorySpec: QuickSpec {
    override func spec() {
        var notebookRepository: FileNotebookRepository!

        beforeEach {
            notebookRepository = FileNotebookRepository()
        }
    }
}
