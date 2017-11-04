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
        let model = Experimental.Library.Model(notebooks: [])
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
                let notebookModel = Experimental.Notebook.Model(uuid: "notebookUUID",
                                                                name: "notebookName",
                                                                notes: [])
                let expectedMeta = Experimental.Notebook.Meta(uuid: "notebookUUID", name: "notebookName")

                beforeEach {
                    event = .addNotebook(notebook: notebookModel)
                }

                context("when notebook with that uuid is not added yet") {
                    it("has createFile action with notebook meta url") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.createFile(url: URL(string: "notebookUUID.qvnotebook/meta.json")!,
                                                  content: expectedMeta)))
                    }

                    it("updates model by adding passed notebook") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(equal([notebookModel]))
                    }
                }

                context("when notebook with that uuid is already added") {
                    let alreadyAddedNotebook = Experimental.Notebook.Model(uuid: "notebookUUID",
                                                                           name: "",
                                                                           notes: [])
                    beforeEach {
                        e = e.evaluate(event: .addNotebook(notebook: alreadyAddedNotebook))
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }

                    it("doesnt update model") {
                        let model = e.evaluate(event: event).model
                        expect(model.notebooks.count).to(equal(1))
                        expect(model.notebooks[0]).to(equal(alreadyAddedNotebook))
                    }
                }
            }
        }
    }
}
