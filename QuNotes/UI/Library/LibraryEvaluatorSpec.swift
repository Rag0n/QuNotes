//
//  LibraryEvaluatorSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 19.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class LibraryEvaluatorSpec: QuickSpec {
    override func spec() {
        var e: UI.Library.Evaluator!
        let underlyingError = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])
        let error = AnyError(underlyingError)

        beforeEach {
            e = UI.Library.Evaluator()
        }

        describe("-evaluate:ViewControllerEvent") {
            var event: UI.Library.ViewControllerEvent!

            context("when receiving addNotebook event") {
                let notebookModel = Experimental.Notebook.Model(uuid: "newUUID", name: "", notes: [])
                let notebookMeta = Experimental.Notebook.Meta(uuid: "newUUID", name: "")

                let firstNotebookMeta = Experimental.Notebook.Meta(uuid: "firstUUID", name: "abc")
                let secondNotebookMeta = Experimental.Notebook.Meta(uuid: "secondUUID", name: "cde")
                let expectedViewModels = [
                    UI.Library.NotebookViewModel(title: "", isEditable: false), // TODO: replace by true
                    UI.Library.NotebookViewModel(title: "abc", isEditable: false),
                    UI.Library.NotebookViewModel(title: "cde", isEditable: false),
                ]

                beforeEach {
                    e = UI.Library.Evaluator(notebooks:  [firstNotebookMeta, secondNotebookMeta])
                    event = .addNotebook
                }

                it("creates notebook model with unique uuid") {
                    let firstAction = e.evaluate(event: event).actions[0]
                    let secondAction = e.evaluate(event: event).actions[0]
                    expect(firstAction).toNot(equal(secondAction))
                }

                it("updates model by adding notebook meta and sorting notebooks") {
                    e.uuidGenerator = { "newUUID" }
                    expect(e.evaluate(event: event).model.notebooks)
                        .to(equal([notebookMeta, firstNotebookMeta, secondNotebookMeta]))
                }

                it("has addNotebook action with notebook model") {
                    e.uuidGenerator = { "newUUID" }
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.addNotebook(notebook: notebookModel)))
                }

                it("has addNotebook effect with correct viewModels and index") {
                    expect(e.evaluate(event: event).effects[0])
                        .to(equal(.addNotebook(index: 0, notebooks: expectedViewModels)))
                }
            }

            context("when receiving deleteNotebook event") {
                let firstNotebookMeta = Experimental.Notebook.Meta(uuid: "firstUUID", name: "abc")
                let secondNotebookMeta = Experimental.Notebook.Meta(uuid: "secondUUID", name: "cde")
                let expectedViewModels = [UI.Library.NotebookViewModel(title: "cde", isEditable: false)]
                let model = UI.Library.Model(notebooks: [firstNotebookMeta, secondNotebookMeta])

                beforeEach {
                    e = UI.Library.Evaluator(notebooks: [firstNotebookMeta, secondNotebookMeta])
                    event = .deleteNotebook(index: 0)
                }

                context("when notebook with that index exists") {
                    beforeEach {
                        event = .deleteNotebook(index: 0)
                    }

                    it("updates model by removing notebook meta") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(equal([secondNotebookMeta]))
                    }

                    it("has deleteNotebook action with correct notebook") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.deleteNotebook(notebook: firstNotebookMeta)))
                    }

                    it("has addNotebook effect with correct viewModels and index") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.deleteNotebook(index: 0, notebooks: expectedViewModels)))
                    }
                }

                context("when notebook with that index doesnt exist") {
                    beforeEach {
                        event = .deleteNotebook(index: 3)
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model)
                            .to(equal(model))
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }

                    it("hasnt got any effects") {
                        expect(e.evaluate(event: event).effects)
                            .to(beEmpty())
                    }
                }
            }

            context("when receiving selectNotebook event") {
                beforeEach {
                    event = .selectNotebook(index: 0)
                }
            }

            context("when receiving updateNotebook event") {
            }
        }

        describe("-evaluate:CoordinatorEvent") {
            var event: UI.Library.CoordinatorEvent!

            context("when receiving didAddNotebook event") {
                let notebook = Experimental.Notebook.Meta(uuid: "uuid", name: "name")
                let anotherNotebook = Experimental.Notebook.Meta(uuid: "anotherUUID", name: "anotherName")
                let anotherNotebookViewModel = UI.Library.NotebookViewModel(title: "anotherName", isEditable: false)
                let model = UI.Library.Model(notebooks: [notebook, anotherNotebook])

                beforeEach {
                    e = UI.Library.Evaluator(notebooks: [notebook, anotherNotebook])
                }

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

                    it("hasnt got any effects") {
                        expect(e.evaluate(event: event).effects)
                            .to(beEmpty())
                    }
                }

                context("when failed to add notebook") {
                    beforeEach {
                        event = .didAddNotebook(notebook: notebook, error: underlyingError)
                    }

                    it("removes that notebook from model") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(equal([anotherNotebook]))
                    }

                    it("has updateAllNotebooks effect with view models without notebook") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateAllNotebooks(notebooks: [anotherNotebookViewModel])))
                    }

                    it("has showError action with message from error") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.showError(title: "Failed to add notebook", message: "message")))
                    }
                }
            }

            context("when receiving didDeleteNotebook event") {
                let notebook = Experimental.Notebook.Meta(uuid: "uuid", name: "name")
                let notebookViewModel = UI.Library.NotebookViewModel(title: "name", isEditable: false)
                let anotherNotebook = Experimental.Notebook.Meta(uuid: "anotherUUID", name: "anotherName")
                let anotherNotebookViewModel = UI.Library.NotebookViewModel(title: "anotherName", isEditable: false)
                let model = UI.Library.Model(notebooks: [anotherNotebook])

                beforeEach {
                    e = UI.Library.Evaluator(notebooks: [anotherNotebook])
                }

                context("when successfully deletes notebook") {
                    beforeEach {
                        event = .didDeleteNotebook(notebook: notebook, error: nil)
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model)
                            .to(equal(model))
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }

                    it("hasnt got any effects") {
                        expect(e.evaluate(event: event).effects)
                            .to(beEmpty())
                    }
                }

                context("when fails to delete notebook") {
                    beforeEach {
                        event = .didDeleteNotebook(notebook: notebook, error: error)
                    }

                    it("adds that notebook back to model") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(equal([anotherNotebook, notebook]))
                    }

                    it("has updateAllNotebooks effect with view models with notebook") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateAllNotebooks(notebooks: [anotherNotebookViewModel,
                                                                      notebookViewModel])))
                    }

                    it("has showError action with message from error") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.showError(title: "Failed to delete notebook", message: "message")))
                    }
                }
            }
        }
    }
}
