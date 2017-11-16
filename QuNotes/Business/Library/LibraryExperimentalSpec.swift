//
//  LibraryExperimentalSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 03.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class LibraryExperimantalSpec: QuickSpec {
    override func spec() {
        let notebook = Experimental.Notebook.Model(uuid: "notebookUUID",
                                                   name: "notebookName",
                                                   notes: [])
        let model = Experimental.Library.Model(notebooks: [notebook])
        let e = Experimental.Library.Evaluator(model: model)
        let error = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])

        context("when initialized") {
            it("has zero actions") {
                expect(e.actions).to(beEmpty())
            }

            it("has passed model") {
                expect(e.model).to(equal(model))
            }
        }

        describe("-evaluate:") {
            var event: Experimental.Library.InputEvent!

            context("when receiving addNotebook event") {
                context("when notebook with that uuid is not added yet") {
                    let newNotebook = Experimental.Notebook.Model(uuid: "newNotebookUUID",
                                                                  name: "newNotebookName",
                                                                  notes: [])

                    beforeEach {
                        event = .addNotebook(notebook: newNotebook)
                    }

                    it("has createNotebook action with notebook meta url") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.createNotebook(notebook: newNotebook,
                                                      url: URL(string: "newNotebookUUID.qvnotebook/meta.json")!)))
                    }

                    it("updates model by adding passed notebook") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(contain(newNotebook))
                    }
                }

                context("when notebook with that uuid is already added") {
                    beforeEach {
                        event = .addNotebook(notebook: notebook)
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model)
                            .to(equal(model))
                    }
                }
            }

            context("when receiving removeNotebook event") {
                context("when notebook with that uuid was added") {
                    beforeEach {
                        event = .removeNotebook(notebook: notebook.meta)
                    }

                    it("removes notebook from model") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .toNot(contain(notebook))
                    }

                    it("has deleteNotebook action with notebook url") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.deleteNotebook(notebook: notebook,
                                                      url: URL(string: "notebookUUID.qvnotebook")!)))
                    }
                }

                context("when notebook with that uuid was not added") {
                    let notAddedNotebook = Experimental.Notebook.Model(uuid: "notAddedNotebookUUID",
                                                                       name: "notAddedNotebookName",
                                                                       notes: [])

                    beforeEach {
                        event = .removeNotebook(notebook: notAddedNotebook.meta)
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model)
                            .to(equal(model))
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }
                }
            }

            context("when receiving loadNotebooks event") {
                beforeEach {
                    event = .loadNotebooks
                }

                it("doesnt update model") {
                    expect(e.evaluate(event: event).model)
                        .to(equal(model))
                }

                it("has readFiles action with root url and qvnotebook extension") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.readFiles(url: URL(string: "/")!, extension: "qvnotebook")))
                }
            }

            context("when receiving didAddNotebook event") {
                let notebook = Experimental.Notebook.Model(uuid: "notebookUUID", name: "notebookName", notes: [])

                context("when successfully adds notebook") {
                    beforeEach {
                        event = .didAddNotebook(notebook: notebook, error: nil)
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model)
                            .to(equal(model))
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }
                }

                context("when failed to add notebook") {
                    context("when notebook is in model") {
                        beforeEach {
                            event = .didAddNotebook(notebook: notebook, error: error)
                        }

                        it("removes notebook from model") {
                            expect(e.evaluate(event: event).model.notebooks)
                                .to(beEmpty())
                        }
                    }

                    context("when notebook is not in model") {
                         let anotherNotebook = Experimental.Notebook.Model(uuid: "anotherNotebookUUID",
                                                                           name: "anotherNotebookName",
                                                                           notes: [])

                        beforeEach {
                            event = .didAddNotebook(notebook: anotherNotebook, error: error)
                        }

                        it("does nothing") {
                            let newE = e.evaluate(event: event)
                            expect(newE.model).to(equal(e.model))
                            expect(newE.actions).to(equal(e.actions))
                        }
                    }
                }
            }

            context("when receiving didRemoveNotebook event") {
                let notebook = Experimental.Notebook.Model(uuid: "removedUUID", name: "removeName", notes: [])

                context("when successfully removes notebook") {
                    beforeEach {
                        event = .didRemoveNotebook(notebook: notebook, error: nil)
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model)
                            .to(equal(model))
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }
                }

                context("when fails to remove notebook") {
                    beforeEach {
                        event = .didRemoveNotebook(notebook: notebook, error: error)
                    }

                    it("adds notebook back to model") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(contain(notebook))
                    }
                }
            }
        }
    }
}
