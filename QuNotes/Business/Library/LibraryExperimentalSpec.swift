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
                    let notebookMeta = Experimental.Notebook.Meta(uuid: "newNotebookUUID", name: "newNotebookName")

                    beforeEach {
                        event = .addNotebook(notebook: newNotebook)
                    }

                    it("has createNotebook action with notebook meta url") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.createNotebook(notebook: notebookMeta,
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

            context("when receiving failedToAddNotebook event") {
                context("when notebook is in model") {
                    let notebookMeta = Experimental.Notebook.Meta(uuid: "notebookUUID", name: "notebookName")

                    beforeEach {
                        event = .failedToAddNotebook(notebook: notebookMeta)
                    }

                    it("removes notebook from model") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(beEmpty())
                    }
                }

                context("when notebook is not in model") {
                    let notebookMeta = Experimental.Notebook.Meta(uuid: "anotherUUID", name: "anotherNotebookName")

                    beforeEach {
                        event = .failedToAddNotebook(notebook: notebookMeta)
                    }

                    it("does nothing") {
                        let newE = e.evaluate(event: event)
                        expect(newE.model).to(equal(e.model))
                        expect(newE.actions).to(equal(e.actions))
                    }
                }
            }

            context("when receiving removeNotebook event") {
                context("when notebook with that uuid was added") {
                    beforeEach {
                        event = .removeNotebook(notebook: notebook)
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
                        event = .removeNotebook(notebook: notAddedNotebook)
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
        }
    }
}
