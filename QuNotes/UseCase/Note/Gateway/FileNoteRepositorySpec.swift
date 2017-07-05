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
        var fileManagerFake: FileManagerFake!

        beforeEach {
            fileManagerFake = FileManagerFake()
            noteRepository = FileNoteRepository(withFileManager: fileManagerFake)
        }

        describe("-getAll") {

        }

        describe("-save") {

            let note = Note(createdDate: 0, updatedDate: 0, content: "content", title: "title", uuid: "2F1535F5-0B62-4CFC-8B5A-2C399B718E57")
            let expectedString = """
            {
              "createdDate" : 0,
              "content" : "content",
              "updatedDate" : 0,
              "title" : "title",
              "uuid" : "2F1535F5-0B62-4CFC-8B5A-2C399B718E57"
            }
            """

            it("writes correct content to file") {
                noteRepository.save(note: note)
                let stringFromPassedData = String(data: fileManagerFake.dataPassedInCreateFileMethod!, encoding: .utf8)
                expect(stringFromPassedData).to(equal(expectedString))
            }

            it("writes to correct file path") {
                noteRepository.save(note: note)
                expect(fileManagerFake.pathPassedInCreateFileMethod).to(contain("Documents/2F1535F5-0B62-4CFC-8B5A-2C399B718E57.qvnote"))
            }
        }
        
        describe("-delete") {
        }
    }
}

class FileManagerFake: FileManager {
    var pathPassedInCreateFileMethod: String?
    var dataPassedInCreateFileMethod: Data?
    var resultToBeReturnedFromCreateFileMethod = false

    override func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]? = nil) -> Bool {
        pathPassedInCreateFileMethod = path
        dataPassedInCreateFileMethod = data

        return resultToBeReturnedFromCreateFileMethod
    }
}
