//
// Created by Alexander Guschin on 10.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class LibrarySpec: QuickSpec {
    override func spec() {

        var library: Library!

        beforeEach {
            library = Library()
        }

        describe("-allNotebooks") {
            context("when created") {
                it("returns zero notebooks") {
                    let notebooks = library.allNotebooks()
                    expect(notebooks.count).to(equal(0))
                }
            }
        }

        describe("-addNotebook") {
            it("adds notebook") {
                let notebook = Notebook()
                library.addNotebook(notebook)
                let notebooks = library.allNotebooks()
                expect(notebooks.count).to(equal(1))
            }
        }

        describe("-removeNotebook") {

            var notebookToRemove: Notebook!

            beforeEach {
                notebookToRemove = Notebook()
            }

            context("when requested notebook is not added") {

                beforeEach {
                    library.addNotebook(Notebook())
                }

                it("does nothing") {
                    library.removeNotebook(notebookToRemove)
                    let notebooks = library.allNotebooks()
                    expect(notebooks.count).to(equal(1))
                }
            }

            context("when requested notebook is added") {

                beforeEach {
                    library.addNotebook(Notebook())
                    library.addNotebook(notebookToRemove)
                }

                it("removes notebook") {
                    library.removeNotebook(notebookToRemove)
                    let notebooks = library.allNotebooks()
                    expect(notebooks.count).to(equal(1))
                }
            }
        }
    }
}
