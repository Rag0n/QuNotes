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
        var noteRepository: FileNoteRepository!

        beforeEach {
            noteRepository = FileNoteRepository()
        }

        describe("-getAll") {
            context("when fileManager is unable to get document directory") {
                beforeEach {
                    noteRepository.fileManager = EmptyURLsFileManagerStub()
                }

                it("returns result with failedToFindDocumentDirectory error") {
                    let error = noteRepository.getAll().error
                    let underlyingError = (error!.error) as? FileNoteRepositoryError
                    expect(underlyingError).to(equal(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }
            }

            context("when fileManager successfully gets document directory") {
                context("when fileManager fails to receive contents of directory") {
                    beforeEach {
                        noteRepository.fileManager = ReturningURLsAndFailingToReadContentsOfDirectoryManagerStub()
                    }

                    it("returns result with error") {
                        let error = noteRepository.getAll().error
                        let underlyingError = (error!.error) as? FileNoteRepositoryError
                        expect(underlyingError).to(equal(ReturningURLsAndFailingToReadContentsOfDirectoryManagerStub.error))
                    }
                }

                context("when fileManager successfully receives contents of directory") {
                    beforeEach {
                        noteRepository.fileManager = ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub()
                    }

                    context("when fileReader fails to read a file") {
                        let fileReaderStub = ThrowingFileReaderStub()

                        beforeEach {
                            noteRepository.fileReader = fileReaderStub
                        }

                        it("returns result with error") {
                            let error = noteRepository.getAll().error
                            let underlyingError = (error!.error) as NSError
                            expect(underlyingError).to(equal(fileReaderStub.thrownError))
                        }
                    }

                    context("when fileReader successfully reads a file") {
                        let fileReaderSpy = NoteDummyFileReaderSpy()

                        beforeEach {
                            noteRepository.fileReader = fileReaderSpy
                        }

                        it("reads data from qvnote urls") {
                            _ = noteRepository.getAll()
                            expect(fileReaderSpy.dataFromFileURLs).to(equal([ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub.firstNoteURL, ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub.secondNoteURL]))
                        }

                        it("returns decoded notes") {
                            let notes = noteRepository.getAll().value
                            expect(notes?[0]).to(equal(fileReaderSpy.noteDummy))
                            expect(notes?[1]).to(equal(fileReaderSpy.noteDummy))
                        }
                    }
                }
            }
        }

        describe("-get:noteId") {
            context("when fileManager is unable to get document directory") {
                beforeEach {
                    noteRepository.fileManager = EmptyURLsFileManagerStub()
                }

                it("returns result with failedToFindDocumentDirectory error") {
                    let error = noteRepository.get(noteId: "noteId").error
                    let underlyingError = (error!.error) as? FileNoteRepositoryError
                    expect(underlyingError).to(equal(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }
            }

            context("when fileManager successfully gets document directory") {
                let fileReaderSpy = FileReaderSpy()

                beforeEach {
                    noteRepository.fileManager = ReturningURLsFileManagerStub()
                    noteRepository.fileReader = fileReaderSpy
                }
                
                it("reads data from correct url") {
                    _ = noteRepository.get(noteId: "noteId")
                    expect(fileReaderSpy.dataFromFileURLs.first?.absoluteString).to(equal("Documents/noteId.qvnote"))
                }

                context("when fileReader fails to read a file") {
                    let fileReaderStub = ThrowingFileReaderStub()

                    beforeEach {
                        noteRepository.fileReader = fileReaderStub
                    }

                    it("returns result with error") {
                        let error = noteRepository.get(noteId: "noteId").error
                        let underlyingError = (error!.error) as NSError
                        expect(underlyingError).to(equal(fileReaderStub.thrownError))
                    }
                }

                context("when fileReader successfully reads a file") {
                    let fileReaderSpy = NoteDummyFileReaderSpy()

                    beforeEach {
                        noteRepository.fileReader = fileReaderSpy
                    }

                    it("returns decoded note") {
                        let note = noteRepository.get(noteId: "noteId").value
                        expect(note).to(equal(fileReaderSpy.noteDummy))
                    }
                }
            }
        }

        describe("-save") {
            let note = Note.noteDummy(withUUID: "2F1535F5-0B62-4CFC-8B5A-2C399B718E57", tags: ["tag fixture", "another tag fixture"])

            context("when fileManager is unable to get document directory") {
                beforeEach {
                    noteRepository.fileManager = EmptyURLsFileManagerStub()
                }

                it("returns result with failedToFindDocumentDirectory error") {
                    let error = noteRepository.save(note: note).error
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

                var fileManagerSpy: ReturningURLsAndSuccessfullyCreatingFileFileManagerSpy!

                beforeEach {
                    fileManagerSpy = ReturningURLsAndSuccessfullyCreatingFileFileManagerSpy()
                    noteRepository.fileManager = fileManagerSpy
                }

                it("writes correct content to file") {
                    _ = noteRepository.save(note: note)
                    let stringFromPassedData = String(data: fileManagerSpy.passedData!, encoding: .utf8)
                    expect(stringFromPassedData).to(equal(expectedString))
                }

                it("writes to correct file path") {
                    _ = noteRepository.save(note: note)
                    expect(fileManagerSpy.passedPath).to(equal("Documents/2F1535F5-0B62-4CFC-8B5A-2C399B718E57.qvnote"))
                }

                context("when fileManager fails to create file") {
                    beforeEach {
                        noteRepository.fileManager = ReturningURLsAndFailingToCreateFileFileManagerSpy()
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
            let note = Note.noteDummy(withUUID: "2F1535F5-0B62-4CFC-8B5A-2C399B718E57")
            
            context("when fileManager is unable to get document directory") {
                beforeEach {
                    noteRepository.fileManager = EmptyURLsFileManagerStub()
                }

                it("returns result with failedToFindDocumentDirectory error") {
                    let error = noteRepository.delete(note: note).error
                    let underlyingError = (error!.error) as? FileNoteRepositoryError
                    expect(underlyingError).to(equal(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }
            }

            context("when fileManager successfully gets document directory") {

                var fileManagerSpy: ReturningURLsAndFailingToRemoveItemFileManagerSpy!

                beforeEach {
                    fileManagerSpy = ReturningURLsAndFailingToRemoveItemFileManagerSpy()
                    noteRepository.fileManager = fileManagerSpy
                }

                it("calls deleteItem of fileManager with correct URL") {
                    _ = noteRepository.delete(note: note)
                    expect(fileManagerSpy.passedURL?.path).to(equal("Documents/2F1535F5-0B62-4CFC-8B5A-2C399B718E57.qvnote"))
                }

                context("when fileManager throws error while removing file") {
                    it("returns result with throw error") {
                        let error = noteRepository.delete(note: note).error
                        let underlyingError = (error!.error) as! FileNoteRepositoryError
                        expect(underlyingError).to(equal(ReturningURLsAndFailingToRemoveItemFileManagerSpy.error))
                    }
                }

                context("when fileManager successfuly removes file") {
                    beforeEach {
                        noteRepository.fileManager = ReturningURLsAndSuccessfullyRemovingItemFileManagerSpy()
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

// MARK: - FileManager repository stubs & spys

class FailingFileManagerStub: FileManager {
    static let error = FileNoteRepositoryError.failedToFindDocumentDirectory

    override func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]? = nil) -> Bool {
        return false
    }

    override func removeItem(at URL: URL) throws {
        throw FailingFileManagerStub.error
    }

    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return []
    }

    override func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
        throw FailingFileManagerStub.error
    }
}

class EmptyURLsFileManagerStub: FailingFileManagerStub {}
class ReturningURLsFileManagerStub: FailingFileManagerStub {
    let returnedURL = URL(string: "Documents")!

    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return [returnedURL]
    }
}

class ReturningURLsAndCreatingFileFileManagerSpy: ReturningURLsFileManagerStub {
    private(set) var passedPath: String?
    private(set) var passedData: Data?

    override func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]? = nil) -> Bool {
        passedData = data
        passedPath = path
        return false
    }
}
class ReturningURLsAndFailingToCreateFileFileManagerSpy: ReturningURLsAndCreatingFileFileManagerSpy {}
class ReturningURLsAndSuccessfullyCreatingFileFileManagerSpy: ReturningURLsAndCreatingFileFileManagerSpy {
    override func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]? = nil) -> Bool {
        _ = super.createFile(atPath: path, contents: data, attributes: attr)
        return true
    }
}

class ReturningURLsAndRemovingItemFileManagerSpy: ReturningURLsFileManagerStub {
    private(set) var passedURL: URL?

    override func removeItem(at URL: URL) throws {
        passedURL = URL
    }
}
class ReturningURLsAndFailingToRemoveItemFileManagerSpy: ReturningURLsAndRemovingItemFileManagerSpy {
    override func removeItem(at URL: URL) throws {
        try super.removeItem(at: URL)
        throw ReturningURLsAndRemovingItemFileManagerSpy.error
    }
}
class ReturningURLsAndSuccessfullyRemovingItemFileManagerSpy: ReturningURLsAndRemovingItemFileManagerSpy {}

class ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub: ReturningURLsFileManagerStub {
    static let firstNoteURL = URL(string: "documents/firstNote.qvnote")!
    static let secondNoteURL = URL(string: "documents/secondNote.qvnote")!
    static let firstNotebookURL = URL(string: "documents/firstNotebook.qvnotebook")!
    static let secondNotebookURL = URL(string: "documents/secondNotebook.qvnotebook")!

    override func contentsOfDirectory(at url: URL, includingPropertiesForKeys keys: [URLResourceKey]?, options mask: FileManager.DirectoryEnumerationOptions = []) throws -> [URL] {
        return [ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub.firstNoteURL,
                ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub.secondNoteURL,
                ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub.firstNotebookURL,
                ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub.secondNotebookURL]
    }
}
class ReturningURLsAndFailingToReadContentsOfDirectoryManagerStub: ReturningURLsFileManagerStub {}

// MARK: - FileReaderSpy

class FileReaderSpy: FileReaderService {
    private(set) var dataFromFileURLs = [URL]()

    func dataFrom(fileURL: URL) throws -> Data {
        dataFromFileURLs.append(fileURL)
        return data()
    }

    func data() -> Data {
        return Data()
    }
}

// MARK: - NoteDummyFileReaderSpy

class NoteDummyFileReaderSpy: FileReaderSpy {
    let noteDummy = Note.noteDummy()

    override func data() -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(noteDummy)
    }
}

// MARK: - ThrowingFileReaderStub

class ThrowingFileReaderStub: FileReaderService {
    private(set) var thrownError = NSError(domain: "domain", code: 0, userInfo: nil)

    func dataFrom(fileURL: URL) throws -> Data {
        throw thrownError
    }
}
