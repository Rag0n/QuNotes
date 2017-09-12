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

// MARK: - FileNoteRepositorySpec

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
            context("when fileManager is unable to get document directory") {

                beforeEach {
                    fileManagerFake.urlsToReturnFromUrlsMethod = []
                }

                it("returns result with failedToFindDocumentDirectory error") {
                    let error = noteRepository.delete(note: note).error
                    let underlyingError = (error!.error) as? FileNoteRepositoryError
                    expect(underlyingError).to(equal(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }
            }

            context("when fileManager successfully gets document directory") {

                it("passed reads data from correct url") {
                    _ = noteRepository.get(noteId: "noteId")
                    expect(fileReaderFake.fileURLPassedInDataFromFileURLMethod?.absoluteString).to(equal("Documents/noteId.qvnote"))
                }

                context("when fileReader fails to read a file") {

                    let thrownError = NSError(domain: "domain", code: 0, userInfo: nil)

                    beforeEach {
                        fileReaderFake.errorToThrowInDataFromMethod = thrownError
                    }

                    it("returns result with error") {
                        let error = noteRepository.get(noteId: "noteId").error
                        let underlyingError = (error!.error) as NSError
                        expect(underlyingError).to(equal(thrownError))
                    }
                }

                context("when fileReader successfully reads a file") {

                    let encodedNote = Note.noteFixture()

                    beforeEach {
                        let encoder = JSONEncoder()
                        let data = try! encoder.encode(encodedNote)
                        fileReaderFake.dataToBeReturnedFromDataFromFileURLMethod = data
                    }

                    it("returns decoded note") {
                        let note = noteRepository.get(noteId: "noteId").value
                        expect(note).to(equal(encodedNote))
                    }
                }
            }
        }

        describe("-save") {
            context("when fileManager is unable to get document directory") {

                beforeEach {
                    fileManagerFake.urlsToReturnFromUrlsMethod = []
                }

                it("returns result with failedToFindDocumentDirectory error") {
                    let error = noteRepository.delete(note: note).error
                    let underlyingError = (error!.error) as? FileNoteRepositoryError
                    expect(underlyingError).to(equal(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }
            }

            context("when fileManager successfully gets document directory") {

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

                context("when fileManager fails to create file") {

                    beforeEach {
                        fileManagerFake.createFileMethodFails = true
                    }

                    it("returns result with error") {
                        let error = noteRepository.save(note: note).error
                        let underlyingError = (error!.error) as? FileNoteRepositoryError
                        expect(underlyingError).to(equal(FileNoteRepositoryError.failedToCreateFile))
                    }
                }

                context("when fileManager successfully creates file") {
                    it("returns result with saved note") {
                        let savedNote = noteRepository.save(note: note).value
                        expect(savedNote).to(equal(note))
                    }
                }
            }
        }
        
        describe("-delete") {
            context("when fileManager is unable to get document directory") {

                beforeEach {
                    fileManagerFake.urlsToReturnFromUrlsMethod = []
                }

                it("returns result with failedToFindDocumentDirectory error") {
                    let error = noteRepository.delete(note: note).error
                    let underlyingError = (error!.error) as? FileNoteRepositoryError
                    expect(underlyingError).to(equal(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }
            }

            context("when fileManager successfully gets document directory") {
                it("calls deleteItem of fileManager with correct URL") {
                    _ = noteRepository.delete(note: note)
                    expect(fileManagerFake.urlPassedInDeleteItemMethod?.path).to(equal("Documents/2F1535F5-0B62-4CFC-8B5A-2C399B718E57.qvnote"))
                }

                context("when fileManager throws error while removing file") {

                    let thrownError = NSError(domain: "domain", code: 0, userInfo: nil)

                    beforeEach {
                        fileManagerFake.errorToThrowInRemoveItemMethod = thrownError
                    }

                    it("returns result with throw error") {
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

// MARK: - FileManagerFake

class FileManagerFake: FileManager {
    var pathPassedInCreateFileMethod: String?
    var dataPassedInCreateFileMethod: Data?
    var createFileMethodFails = false

    override func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]? = nil) -> Bool {
        pathPassedInCreateFileMethod = path
        dataPassedInCreateFileMethod = data

        return !createFileMethodFails
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

// MARK: - FileReaderServiceFake

class FileReaderServiceFake: FileReaderService {
    var fileURLPassedInDataFromFileURLMethod: URL?
    var dataToBeReturnedFromDataFromFileURLMethod: Data?
    var errorToThrowInDataFromMethod: NSError?

    func dataFrom(fileURL: URL) throws -> Data {
        fileURLPassedInDataFromFileURLMethod = fileURL
        if let errorToThrowInDataFromMethod = errorToThrowInDataFromMethod {
            throw errorToThrowInDataFromMethod
        }
        return dataToBeReturnedFromDataFromFileURLMethod ?? Data()
    }
}
