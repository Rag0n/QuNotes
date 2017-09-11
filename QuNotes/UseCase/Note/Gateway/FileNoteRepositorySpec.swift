//
//  FileNoteRepositorySpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 04.07.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

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
                _ = noteRepository.save(note: note)
                let stringFromPassedData = String(data: fileManagerFake.dataPassedInCreateFileMethod!, encoding: .utf8)
                expect(stringFromPassedData).to(equal(expectedString))
            }

            it("writes to correct file path") {
                _ = noteRepository.save(note: note)
                expect(fileManagerFake.pathPassedInCreateFileMethod).to(equal("Documents/2F1535F5-0B62-4CFC-8B5A-2C399B718E57.qvnote"))
            }
        }
        
        describe("-delete") {
            it("calls deleteItem of fileManager with correct URL") {
                _ = noteRepository.delete(note: note)
                expect(fileManagerFake.urlPassedInDeleteItemMethod?.path).to(equal("Documents/2F1535F5-0B62-4CFC-8B5A-2C399B718E57.qvnote"))
            }

            context("when fileManager is unable to get document directory") {

                let thrownError = FileNoteRepositoryError.failedToFindDocumentDirectory

                beforeEach {
                    fileManagerFake.urlsToReturnFromUrlsMethod = []
                }

                it("returns result with throws error wrapped in AnyError") {
                    let error = noteRepository.delete(note: note).error
                    let underlyingError = (error!.error) as? FileNoteRepositoryError
                    expect(underlyingError).to(equal(thrownError))
                }
            }

            context("when fileManager successfully gets document directory") {
                context("when fileManager throws error while removing file") {

                    let thrownError = NSError(domain: "domain", code: 0, userInfo: nil)

                    beforeEach {
                        fileManagerFake.errorToThrowInRemoveItemMethod = thrownError
                    }

                    it("returns result with throws error wrapped in AnyError") {
                        let error = noteRepository.delete(note: note).error
                        let underlyingError = (error!.error) as NSError
                        expect(underlyingError).to(equal(thrownError))
                    }
                }

                context("when fileManager successfuly removes file") {

                    beforeEach {
                        fileManagerFake.errorToThrowInRemoveItemMethod = nil
                    }

                    it("returns result with deleted note") {
                        let deletedNote = noteRepository.delete(note: note).value
                        expect(deletedNote).to(equal(note))
                    }
                }
            }
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

    var urlPassedInDeleteItemMethod: URL?
    var errorToThrowInRemoveItemMethod: NSError?

    override func removeItem(at URL: URL) throws {
        urlPassedInDeleteItemMethod = URL
        if let errorToThrowInRemoveItemMethod = errorToThrowInRemoveItemMethod {
            throw errorToThrowInRemoveItemMethod
        }
    }

    var urlsToReturnFromUrlsMethod: [URL]?

    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return urlsToReturnFromUrlsMethod ?? [URL(string: "Documents")!]
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
