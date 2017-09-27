//
//  NotebookUseCaseSpec.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

// MARK: - NotebookUseCaseSpec

class NotebookUseCaseSpec: QuickSpec {
    override func spec() {
        var useCase: NotebookUseCase!

        beforeEach {
            useCase = NotebookUseCase()
        }

        describe("-getAll") {
            context("when repository returns error") {
                beforeEach {
                    useCase.repository = FailingToGetNotebookRepositoryStub()
                }

                it("returns empty array") {
                    expect(useCase.getAll()).to(beEmpty())
                }
            }

            context("when repository returns array of notebooks") {
                beforeEach() {
                    useCase.repository = ReturningArrayOfNotebooksRepositoryStub()
                }

                it("returns notebooks from repository") {
                    let notebooks = useCase.getAll()
                    expect(notebooks).to(equal(ReturningArrayOfNotebooksRepositoryStub.notebooks))
                }
            }
        }

        describe("-add:") {
            context("when save method succedes") {
                beforeEach {
                    useCase.repository = SuccessfullySavingNotebookRepositorySpy()
                }

                it("returns notebook with passed name") {
                    let notebook = useCase.add(withName: "notebook name").value
                    expect(notebook?.name).to(equal("notebook name"))
                }

                it("returns notebook with uniq uuid") {
                    let firstNotebook = useCase.add(withName: "first notebook name").value
                    let secondNotebook = useCase.add(withName: "second notebook name").value
                    expect(firstNotebook?.uuid).toNot(equal(secondNotebook?.uuid))
                }
            }

            context("when save method fails") {
                beforeEach {
                    useCase.repository = FailingToSaveNotebookRepositoryStub()
                }

                it("return result with save error") {
                    let error = useCase.add(withName: "notebook name").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(FailingToSaveNotebookRepositoryStub.error))
                }
            }
        }

        describe("-update:name") {
            var oldNotebook: Notebook!

            beforeEach {
                useCase.repository = SuccessfullySavingNotebookRepositorySpy()
                oldNotebook = useCase.add(withName: "old name").value
            }

            context("when save method succedes") {
                beforeEach {
                    useCase.repository = SuccessfullySavingNotebookRepositorySpy()
                }

                it("returns notebook with updated name") {
                    let updatedNotebook = useCase.update(oldNotebook, name: "new name").value
                    expect(updatedNotebook?.name).to(equal("new name"))
                }

                it("returns notebook with same uuid") {
                    let updatedNotebook = useCase.update(oldNotebook, name: "new name").value
                    expect(updatedNotebook?.uuid).to(equal(oldNotebook.uuid))
                }
            }

            context("when save method fails") {
                beforeEach {
                    useCase.repository = FailingToSaveNotebookRepositoryStub()
                }

                it("return result with save error") {
                    let error = useCase.update(oldNotebook, name: "new name").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(FailingToSaveNotebookRepositoryStub.error))
                }
            }
        }

        describe("-delete:") {
            let notebook = Notebook.notebookDummy()
            var deletingRepositorySpy: SuccessfullyDeletingNotebookRepositorySpy!

            beforeEach {
                deletingRepositorySpy = SuccessfullyDeletingNotebookRepositorySpy()
                useCase.repository = deletingRepositorySpy
            }

            it("calls delete method of repository with passed notebook") {
                _ = useCase.delete(notebook)
                expect(deletingRepositorySpy.passedNotebook).to(equal(notebook))
            }

            context("when repository successfully deletes notebook") {
                it("return result with deleted notebook") {
                    let result = useCase.delete(notebook)
                    expect(result.value).to(equal(notebook))
                }
            }

            context("when repository failes to delete notebook") {
                beforeEach() {
                    useCase.repository = FailingToDeleteNotebookRepositoryStub()
                }

                it("returns result with error from repository") {
                    let error = useCase.delete(notebook).error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(FailingToDeleteNotebookRepositoryStub.error))
                }
            }
        }
    }
}

// MARK: - Notebook repository stubs & spys

class FailingNotebookRepositoryStub: NotebookRepository {
    static let anyError = AnyError(error)
    static let error = FileNoteRepositoryError.failedToFindDocumentDirectory

    func getAll() -> Result<[Notebook], AnyError> {
        return .failure(FailingNotebookRepositoryStub.anyError)
    }

    func save(notebook: Notebook) -> Result<Notebook, AnyError> {
        return .failure(FailingNotebookRepositoryStub.anyError)
    }

    func delete(notebook: Notebook) -> Result<Notebook, AnyError> {
        return .failure(FailingNotebookRepositoryStub.anyError)
    }
}

class FailingToGetNotebookRepositoryStub: FailingNotebookRepositoryStub {}
class FailingToSaveNotebookRepositoryStub: FailingNotebookRepositoryStub {}
class FailingToDeleteNotebookRepositoryStub: FailingNotebookRepositoryStub {}

class ReturningArrayOfNotebooksRepositoryStub: FailingNotebookRepositoryStub {
    static let notebooks = [Notebook.notebookDummy(), Notebook.notebookDummy()]

    override func getAll() -> Result<[Notebook], AnyError> {
        return .success(ReturningArrayOfNotebooksRepositoryStub.notebooks)
    }
}

class SuccessfullySavingNotebookRepositorySpy: FailingNotebookRepositoryStub {
    private(set) var passedNotebook: Notebook?

    override func save(notebook: Notebook) -> Result<Notebook, AnyError> {
        passedNotebook = notebook
        return .success(notebook)
    }
}

class SuccessfullyDeletingNotebookRepositorySpy: FailingNotebookRepositoryStub {
    private(set) var passedNotebook: Notebook?

    override func delete(notebook: Notebook) -> Result<Notebook, AnyError> {
        passedNotebook = notebook
        return .success(notebook)
    }
}
