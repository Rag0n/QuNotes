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

        let note = Note(createdDate: 0, updatedDate: 0, content: "content", title: "title", uuid: "2F1535F5-0B62-4CFC-8B5A-2C399B718E57", tags: ["tag fixture", "another tag fixture"])
        var noteRepository: FileNoteRepository!
        var fileManagerFake: FileManagerFake!
        var fileReaderFake: FileReaderServiceFake!

        beforeEach {
            fileManagerFake = FileManagerFake()
            fileReaderFake = FileReaderServiceFake()
            noteRepository = FileNoteRepository(withFileManager: fileManagerFake, fileReader: fileReaderFake)
        }

        describe("-getAll") {

        }

        describe("-get:noteId") {
            it("passed correct url to fileReaderService") {
                _ = noteRepository.get(noteId: "noteId")
                expect(fileReaderFake.fileURLPassedInDataFromFileURLMethod?.absoluteString).to(equal("Documents/noteId.qvnote"))
            }

            context("when fileReaderService throws an error") {

                beforeEach {
                    fileReaderFake.dataFromFileURLMethodThrowsError = true
                }

                it("returns notFound result") {

                }
            }

            context("when fileReaderService doesnt throw an error") {
                context("when fileReaderService returns invalid data") {
                    
                }

                context("when fileReaderService returns valid data") {

                }
            }
        }

        describe("-save") {

            let expectedString = """
            {
              "createdDate" : 0,
              "content" : "content",
              "updatedDate" : 0,
              "title" : "title",
              "tags" : [
                "tag fixture",
                "another tag fixture"
              ],
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
                expect(fileManagerFake.pathPassedInCreateFileMethod).to(equal("Documents/2F1535F5-0B62-4CFC-8B5A-2C399B718E57.qvnote"))
            }
        }
        
        describe("-delete") {
            it("calls deleteItem of fileManager with correct URL") {
                noteRepository.delete(note: note)
                expect(fileManagerFake.urlPassedInDeleteItemMethod?.path).to(equal("Documents/2F1535F5-0B62-4CFC-8B5A-2C399B718E57.qvnote"))
            }

            context("when fileManager successfuly removes file") {

                beforeEach {
                    fileManagerFake.remoteItemMethodThrows = false
                }
            }

            context("when fileManager throws error when trying to remove file") {

                beforeEach {
                    fileManagerFake.remoteItemMethodThrows = true
                }
            }
        }
    }
}

class FileManagerFake: FileManager {
    var pathPassedInCreateFileMethod: String?
    var dataPassedInCreateFileMethod: Data?
    var resultToBeReturnedFromCreateFileMethod = false
    var urlPassedInDeleteItemMethod: URL?
    var remoteItemMethodThrows = false

    override func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]? = nil) -> Bool {
        pathPassedInCreateFileMethod = path
        dataPassedInCreateFileMethod = data

        return resultToBeReturnedFromCreateFileMethod
    }

    override func removeItem(at URL: URL) throws {
        urlPassedInDeleteItemMethod = URL
        if remoteItemMethodThrows {
            throw NSError(domain: "domain", code: 0, userInfo: nil)
        }
    }

    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return [URL(string: "Documents")!]
    }
}

class FileReaderServiceFake: FileReaderService {
    var fileURLPassedInDataFromFileURLMethod: URL?
    var resultToBeReturnedFromDataFromFileURLMethod: Data?
    var dataFromFileURLMethodThrowsError = false

    func dataFrom(fileURL: URL) throws -> Data {
        fileURLPassedInDataFromFileURLMethod = fileURL
        if dataFromFileURLMethodThrowsError {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        return resultToBeReturnedFromDataFromFileURLMethod ?? Data()
    }
}
