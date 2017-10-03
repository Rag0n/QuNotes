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

        describe("-getAll") {
            context("when fileManager is unable to get document directory") {
                beforeEach {
                    notebookRepository.fileManager = EmptyURLsFileManagerStub()
                }

                it("returns result with failedToFindDocumentDirectory error") {
                    let error = notebookRepository.getAll().error
                    let underlyingError = (error!.error) as? FileNotebookRepositoryError
                    expect(underlyingError).to(equal(FileNotebookRepositoryError.failedToFindDocumentDirectory))
                }
            }

            context("when fileManager successfully gets document directory") {
                context("when fileManager fails to receive contents of directory") {
                    beforeEach {
                        notebookRepository.fileManager = ReturningURLsAndFailingToReadContentsOfDirectoryManagerStub()
                    }

                    it("returns result with error") {
                        let error = notebookRepository.getAll().error
                        let underlyingError = (error!.error) as? FileNoteRepositoryError
                        expect(underlyingError).to(equal(ReturningURLsAndFailingToReadContentsOfDirectoryManagerStub.error))
                    }
                }

                context("when fileManager successfully receives contents of directory") {
                    beforeEach {
                        notebookRepository.fileManager = ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub()
                    }

                    context("when fileReader fails to read a file") {
                        let fileReaderStub = ThrowingFileReaderStub()

                        beforeEach {
                            notebookRepository.fileReader = fileReaderStub
                        }

                        it("returns result with error") {
                            let error = notebookRepository.getAll().error
                            let underlyingError = (error!.error) as NSError
                            expect(underlyingError).to(equal(fileReaderStub.thrownError))
                        }
                    }

                    context("when fileReader successfully reads a file") {
                        let fileReaderSpy = NotebookDummyFileReaderSpy()

                        beforeEach {
                            notebookRepository.fileReader = fileReaderSpy
                        }

                        it("reads data from qvnotebook urls") {
                            _ = notebookRepository.getAll()
                            expect(fileReaderSpy.dataFromFileURLs).to(equal([
                                ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub.firstNotebookURL.appendingPathComponent("meta").appendingPathExtension("json"),
                                ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub.secondNotebookURL.appendingPathComponent("meta").appendingPathExtension("json")
                            ]))
                        }

                        it("returns decoded notes") {
                            let notes = notebookRepository.getAll().value
                            expect(notes?[0]).to(equal(fileReaderSpy.notebookDummy))
                            expect(notes?[1]).to(equal(fileReaderSpy.notebookDummy))
                        }
                    }
                }
            }
        }

        describe("-save:") {
            let notebook = Notebook.notebookDummy(withUUID: "notebookUuid", name: "notebook name")

            context("when fileManager is unable to get document directory") {
                beforeEach {
                    notebookRepository.fileManager = EmptyURLsFileManagerStub()
                }

                it("returns result with failedToFindDocumentDirectory error") {
                    let error = notebookRepository.save(notebook: notebook).error
                    let underlyingError = (error!.error) as? FileNotebookRepositoryError
                    expect(underlyingError).to(equal(FileNotebookRepositoryError.failedToFindDocumentDirectory))
                }
            }

            context("when fileManager successfully gets document directory") {
                let expectedString = """
                {
                  "name" : "notebook name",
                  "uuid" : "notebookUuid"
                }
                """

                var fileManagerSpy: ReturningURLsAndFailingToCreateDirectoryFileManagerSpy!

                beforeEach {
                    fileManagerSpy = ReturningURLsAndFailingToCreateDirectoryFileManagerSpy()
                    notebookRepository.fileManager = fileManagerSpy
                }

                it("creates notebook directory with correct file path") {
                    _ = notebookRepository.save(notebook: notebook)
                    expect(fileManagerSpy.passedPath).to(equal("Documents/notebookUuid.qvnotebook"))
                }

                context("when fileManager fails to create directory") {
                    beforeEach {
                        fileManagerSpy = ReturningURLsAndFailingToCreateDirectoryFileManagerSpy()
                        notebookRepository.fileManager = fileManagerSpy
                    }

                    it("returns result with error") {
                        let error = notebookRepository.save(notebook: notebook).error
                        let underlyingError = (error!.error) as NSError
                        expect(underlyingError).to(equal(fileManagerSpy.thrownError))
                    }
                }

                context("when fileManager successfully creates directory") {

                    var fileManagerSpy: ReturningURLsCreatingDirectoryAndSuccessfullyCreatingFileFileManagerSpy!

                    beforeEach {
                        fileManagerSpy = ReturningURLsCreatingDirectoryAndSuccessfullyCreatingFileFileManagerSpy()
                        notebookRepository.fileManager = fileManagerSpy
                    }

                    it("creates notebook meta file") {
                        _ = notebookRepository.save(notebook: notebook)
                        expect(fileManagerSpy.passedPath).to(equal("Documents/notebookUuid.qvnotebook/meta.json"))
                    }

                    it("writes correct content to file") {
                        _ = notebookRepository.save(notebook: notebook)
                        let stringFromPassedData = String(data: fileManagerSpy.passedData!, encoding: .utf8)
                        expect(stringFromPassedData).to(equal(expectedString))
                    }

                    context("when fileManager fails to create file") {
                        beforeEach {
                            notebookRepository.fileManager = ReturningURLsCreatingDirectoryAndFailingToCreateFileFileManagerSpy()
                        }

                        it("returns result with error") {
                            let error = notebookRepository.save(notebook: notebook).error
                            let underlyingError = (error!.error) as? FileNotebookRepositoryError
                            expect(underlyingError).to(equal(FileNotebookRepositoryError.failedToCreateFile))
                        }
                    }

                    context("when fileManager successfully creates file") {
                        it("returns result with saved note") {
                            let savedNotebook = notebookRepository.save(notebook: notebook).value
                            expect(savedNotebook).to(equal(notebook))
                        }
                    }
                }
            }
        }

        describe("-delete:") {
//            let deletedNotebook = Notebook.notebookDummy()
//
//            beforeEach {
//                _ = repository.save(notebook: deletedNotebook)
//            }
//
//            it("removes notebook from storage") {
//                _ = repository.delete(notebook: deletedNotebook)
//                let notebooks = repository.getAll().value
//                expect(notebooks).to(beEmpty())
//            }
//
//            it("returns passed notebook") {
//                let result = repository.delete(notebook: deletedNotebook)
//                expect(result.value).to(equal(deletedNotebook))
//            }
        }
    }
}

// MARK: - NotebookDummyFileReaderSpy

class NotebookDummyFileReaderSpy: FileReaderSpy {
    let notebookDummy = Notebook.notebookDummy()

    override func data() -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(notebookDummy)
    }
}

class ReturningURLsAndCreatingDirectoryFileManagerSpy: ReturningURLsFileManagerStub {
    private(set) var passedPath: String?
    private(set) var thrownError = NSError(domain: "domain", code: 0, userInfo: nil)

    override func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [String : Any]? = nil) throws {
        passedPath = path
        throw thrownError
    }
}
class ReturningURLsAndFailingToCreateDirectoryFileManagerSpy: ReturningURLsAndCreatingDirectoryFileManagerSpy {}
class ReturningURLsCreatingDirectoryAndFailingToCreateFileFileManagerSpy: ReturningURLsAndCreatingFileFileManagerSpy {
    override func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [String : Any]? = nil) throws {
    }
}
class ReturningURLsCreatingDirectoryAndSuccessfullyCreatingFileFileManagerSpy: ReturningURLsCreatingDirectoryAndFailingToCreateFileFileManagerSpy {
    override func createFile(atPath path: String, contents data: Data?, attributes attr: [String : Any]? = nil) -> Bool {
        _ = super.createFile(atPath: path, contents: data, attributes: attr)
        return true
    }
}
