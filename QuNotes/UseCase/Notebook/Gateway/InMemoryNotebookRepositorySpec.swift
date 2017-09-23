//
//  InMemoryNotebookRepositorySpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 23.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

// MARK: - InMemoryNotebookRepositorySpec

class InMemoryNotebookRepositorySpec: QuickSpec {
    override func spec() {
        var repository: InMemoryNotebookRepository!

        beforeEach {
            repository = InMemoryNotebookRepository()
        }

        describe("-getAll") {
            context("when notebook is added") {
                let addedNotebook = Notebook.notebookDummy()

                beforeEach {
                    _ = repository.save(notebook: addedNotebook)
                }

                it("returns array with added notebook") {
                    let notebooks = repository.getAll().value
                    let notebook = notebooks?.first
                    expect(notebook).to(equal(addedNotebook))
                }
            }

            context("when nothing is added") {
                it("returns empty array") {
                    let notebooks = repository.getAll().value
                    expect(notebooks).to(beEmpty())
                }
            }
        }

        describe("-save:") {
            let savedNotebook = Notebook.notebookDummy()

            it("adds notebook to storage") {
                _ = repository.save(notebook: savedNotebook)
                let notebooks = repository.getAll().value
                expect(notebooks).to(equal([savedNotebook]))
            }

            it("returns passed notebook") {
                let result = repository.save(notebook: savedNotebook)
                expect(result.value).to(equal(savedNotebook))
            }
        }

        describe("-delete:") {
            let deletedNotebook = Notebook.notebookDummy()

            beforeEach {
                _ = repository.save(notebook: deletedNotebook)
            }

            it("removes notebook from storage") {
                _ = repository.delete(notebook: deletedNotebook)
                let notebooks = repository.getAll().value
                expect(notebooks).to(beEmpty())
            }

            it("returns passed notebook") {
                let result = repository.delete(notebook: deletedNotebook)
                expect(result.value).to(equal(deletedNotebook))
            }
        }
    }
}
