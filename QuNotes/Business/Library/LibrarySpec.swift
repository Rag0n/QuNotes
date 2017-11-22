//
//  LibrarySpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 03.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble

class LibraryExperimantalSpec: QuickSpec {
    override func spec() {
        let notebook = Notebook.Model(uuid: "notebookUUID", name: "notebookName", notes: [])
        let model = Library.Model(notebooks: [notebook])
        let error = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])
        var e: Library.Evaluator!

        beforeEach {
            e = Library.Evaluator(model: model)
        }

        context("when initialized") {
            it("has zero actions") {
                expect(e.actions).to(beEmpty())
            }

            it("has passed model") {
                expect(e.model).to(equal(model))
            }
        }

        describe("-evaluate:") {
            var event: Library.InputEvent!

            context("when receiving addNotebook event") {
                context("when notebook with that uuid is not added yet") {
                    let newNotebook = Notebook.Model(uuid: "newNotebookUUID", name: "newNotebookName", notes: [])

                    beforeEach {
                        event = .addNotebook(notebook: newNotebook)
                        e = e.evaluate(event: event)
                    }

                    it("has createNotebook action with notebook & meta url") {
                        expect(e.actions).to(equalDiff([
                            .createNotebook(notebook: newNotebook,
                                             url: URL(string: "newNotebookUUID.qvnotebook/meta.json")!)
                        ]))
                    }

                    it("updates model by adding passed notebook") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [notebook, newNotebook])
                        ))
                    }
                }

                context("when notebook with that uuid is already added") {
                    beforeEach {
                        event = .addNotebook(notebook: notebook)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }
            }

            context("when receiving removeNotebook event") {
                context("when notebook with that uuid was added") {
                    beforeEach {
                        event = .removeNotebook(notebook: notebook.meta)
                        e = e.evaluate(event: event)
                    }

                    it("removes notebook from model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [])
                        ))
                    }

                    it("has deleteNotebook action with notebook url") {
                        expect(e.actions).to(equalDiff([
                            .deleteNotebook(notebook: notebook,
                                            url: URL(string: "notebookUUID.qvnotebook")!)
                        ]))
                    }
                }

                context("when notebook with that uuid was not added") {
                    beforeEach {
                        let notAddedNotebook = Notebook.Model(uuid: "nAUUID", name: "nAName", notes: [])
                        event = .removeNotebook(notebook: notAddedNotebook.meta)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }
            }

            context("when receiving loadNotebooks event") {
                beforeEach {
                    event = .loadNotebooks
                    e = e.evaluate(event: event)
                }

                it("doesnt update model") {
                    expect(e.model).to(equalDiff(model))
                }

                it("has readFiles action with root url and qvnotebook extension") {
                    expect(e.actions).to(equalDiff([
                        .readFiles(url: URL(string: "/")!, extension: "qvnotebook")
                    ]))
                }
            }

            context("when receiving didAddNotebook event") {
                context("when successfully adds notebook") {
                    beforeEach {
                        let notebook = Notebook.Model(uuid: "notebookUUID", name: "notebookName", notes: [])
                        event = .didAddNotebook(notebook: notebook, error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }

                context("when fails to add notebook") {
                    context("when notebook is in model") {
                        beforeEach {
                            event = .didAddNotebook(notebook: notebook, error: error)
                            e = e.evaluate(event: event)
                        }

                        it("removes notebook from model") {
                            expect(e.model).to(equalDiff(
                                Library.Model(notebooks: [])
                            ))
                        }
                    }

                    context("when notebook is not in model") {
                        beforeEach {
                            let anotherNotebook = Notebook.Model(uuid: "aUUID", name: "aName", notes: [])
                            event = .didAddNotebook(notebook: anotherNotebook, error: error)
                            e = e.evaluate(event: event)
                        }

                        it("does nothing") {
                            expect(e.model).to(equal(model))
                            expect(e.actions).to(equal([]))
                        }
                    }
                }
            }

            context("when receiving didRemoveNotebook event") {
                let removedNotebook = Notebook.Model(uuid: "removedUUID", name: "removeName", notes: [])

                context("when successfully removes notebook") {
                    beforeEach {
                        event = .didRemoveNotebook(notebook: removedNotebook, error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }

                context("when fails to remove notebook") {
                    beforeEach {
                        event = .didRemoveNotebook(notebook: removedNotebook, error: error)
                        e = e.evaluate(event: event)
                    }

                    it("adds notebook back to model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [notebook, removedNotebook])
                        ))
                    }
                }
            }
        }
    }
}
