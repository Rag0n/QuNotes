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
                            expect(fileReaderSpy.dataFromFileURLs).to(equal([ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub.firstNotebookURL, ReturningURLsAndSuccessfullyReadingContentsOfDirectoryManagerStub.secondNotebookURL]))
                        }

                        it("returns decoded notes") {
                            let notes = notebookRepository.getAll().value
                            expect(notes?[0]).to(equal(fileReaderSpy.notebookDummy))
                            expect(notes?[1]).to(equal(fileReaderSpy.notebookDummy))
                        }
                    }
                }
            }
//            context("when notebook is added") {
//                let addedNotebook = Notebook.notebookDummy()
//
//                beforeEach {
//                    _ = repository.save(notebook: addedNotebook)
//                }
//
//                it("returns array with added notebook") {
//                    let notebooks = repository.getAll().value
//                    let notebook = notebooks?.first
//                    expect(notebook).to(equal(addedNotebook))
//                }
//            }
//
//            context("when nothing is added") {
//                it("returns empty array") {
//                    let notebooks = repository.getAll().value
//                    expect(notebooks).to(beEmpty())
//                }
//            }
        }

        describe("-save:") {
//            let savedNotebook = Notebook.notebookDummy()
//
//            it("adds notebook to storage") {
//                _ = repository.save(notebook: savedNotebook)
//                let notebooks = repository.getAll().value
//                expect(notebooks).to(equal([savedNotebook]))
//            }
//
//            it("returns passed notebook") {
//                let result = repository.save(notebook: savedNotebook)
//                expect(result.value).to(equal(savedNotebook))
//            }
//
//            context("when saving notebook twice") {
//                it("saves only one recent copy of notebook") {
//                    _ = repository.save(notebook: savedNotebook)
//                    _ = repository.save(notebook: savedNotebook)
//                    let notebooks = repository.getAll().value
//                    expect(notebooks?.count).to(equal(1))
//                }
//            }
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
