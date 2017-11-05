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

class libraryExperimantalSpec: QuickSpec {
    override func spec() {
        let notebookViewModel = Experimental.Notebook.Model(uuid: "NotebookViewModelUUID",
                                                            name: "NotebookViewModelName",
                                                            notes: [])
        let model = Experimental.Library.Model(notebooks: [notebookViewModel])
        var e: Experimental.Library.Evaluator!

        beforeEach {
            e = Experimental.Library.Evaluator(model: model)
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
            var event: Experimental.Library.InputEvent!

            context("when receiving addNotebook event") {
                context("when notebook with that uuid is not added yet") {
                    let newNotebook = Experimental.Notebook.Model(uuid: "NewNotebookUUID",
                                                                  name: "NewNotebookName",
                                                                  notes: [])
                    let expectedMeta = Experimental.Notebook.Meta(uuid: "NewNotebookUUID", name: "NewNotebookName")

                    beforeEach {
                        event = .addNotebook(notebook: newNotebook)
                    }

                    it("has createFile action with notebook meta url") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.createFile(url: URL(string: "NewNotebookUUID.qvnotebook/meta.json")!,
                                                  content: expectedMeta)))
                    }

                    it("updates model by adding passed notebook") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(contain(newNotebook))
                    }
                }

                context("when notebook with that uuid is already added") {
                    beforeEach {
                        event = .addNotebook(notebook: notebookViewModel)
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
                    }
                }
            }
        }
    }
}
