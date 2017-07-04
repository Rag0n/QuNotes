//
//  FileNoteRepositorySpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 04.07.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble

class FileNoteRepositorySpec: QuickSpec {
    override func spec() {

        var noteRepository: FileNoteRepository!

        beforeEach {
            noteRepository = FileNoteRepository(withFileManager: FileManager.default)
        }

        describe("-getAll") {

        }

        describe("-save") {
            it("save file with note json") {
                noteRepository.save(note: Note.noteFixtureWithContent("note fixture"))
            }
        }

        describe("-delete") {
        }
    }
}
