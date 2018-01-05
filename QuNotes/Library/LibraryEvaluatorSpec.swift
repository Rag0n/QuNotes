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
import Core

class LibraryEvaluatorSpec: QuickSpec {
    override func spec() {
        var e: Library.Evaluator!
        let underlyingError = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])
        let error = AnyError(underlyingError)

        beforeEach {
            e = Library.Evaluator()
        }

        describe("-evaluate:ViewEvent") {
            var event: Library.ViewEvent!

            context("when receiving addNotebook event") {
                let notebook = Core.Notebook.Meta(uuid: "newUUID", name: "")

                let firstNotebook = Core.Notebook.Meta(uuid: "firstUUID", name: "abc")
                let secondNotebook = Core.Notebook.Meta(uuid: "secondUUID", name: "cde")
                let expectedViewModels = [
                    Library.NotebookViewModel(title: ""),
                    Library.NotebookViewModel(title: "abc"),
                    Library.NotebookViewModel(title: "cde")
                ]

                beforeEach {
                    e = Library.Evaluator(notebooks:  [firstNotebook, secondNotebook])
                    event = .addNotebook
                }

                it("creates notebook model with unique uuid") {
                    let firstAction = e.evaluate(event: event).actions[0]
                    let secondAction = e.evaluate(event: event).actions[0]
                    expect(firstAction).toNot(equal(secondAction))
                }

                it("updates model by adding notebook meta and sorting notebooks") {
                    e.generateUUID = { "newUUID" }
                    expect(e.evaluate(event: event).model.notebooks)
                        .to(equal([notebook, firstNotebook, secondNotebook]))
                }

                it("has addNotebook action with notebook model") {
                    e.generateUUID = { "newUUID" }
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.addNotebook(notebook)))
                }

                it("has addNotebook effect with correct viewModels and index") {
                    expect(e.evaluate(event: event).effects[0])
                        .to(equal(.addNotebook(index: 0, notebooks: expectedViewModels)))
                }
            }

            context("when receiving deleteNotebook event") {
                let firstNotebook = Core.Notebook.Meta(uuid: "firstUUID", name: "a")
                let secondNotebook = Core.Notebook.Meta(uuid: "secondUUID", name: "c")
                let model = Library.Model(notebooks: [firstNotebook, secondNotebook])

                beforeEach {
                    e = Library.Evaluator(notebooks: [firstNotebook, secondNotebook])
                }

                context("when notebook with that index exists") {
                    beforeEach {
                        event = .deleteNotebook(index: 1)
                        e = e.evaluate(event: event)
                    }

                    it("updates model by removing notebook meta") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [firstNotebook])
                        ))
                    }

                    it("has deleteNotebook action with correct notebook") {
                        expect(e.actions).to(equalDiff([
                            .deleteNotebook(secondNotebook)
                        ]))
                    }

                    it("has addNotebook effect with correct viewModels and index") {
                        expect(e.effects).to(equalDiff([
                            .deleteNotebook(index: 1,
                                            notebooks: [Library.NotebookViewModel(title: "a")])
                        ]))
                    }
                }

                context("when notebook with that index doesnt exist") {
                    beforeEach {
                        event = .deleteNotebook(index: 3)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("hasnt got any actions") {
                        expect(e.actions).to(beEmpty())
                    }

                    it("hasnt got any effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }
            }

            context("when receiving selectNotebook event") {
                beforeEach {
                    event = .selectNotebook(index: 0)
                    e = Library.Evaluator(notebooks: [Core.Notebook.Meta(uuid: "uuid", name: "name")])
                    e = e.evaluate(event: event)
                }

                it("has showNotebook action") {
                    expect(e.actions).to(equalDiff([
                        .showNotebook(Core.Notebook.Meta(uuid: "uuid", name: "name"))
                    ]))
                }
            }
        }

        describe("-evaluate:CoordinatorEvent") {
            var event: Library.CoordinatorEvent!

            context("when receiving updateNotebook event") {
                let notebook = Core.Notebook.Meta(uuid: "uuid", name: "aname")
                let secondNotebook = Core.Notebook.Meta(uuid: "suuid", name: "sname")

                beforeEach {
                    event = .updateNotebook(notebook)
                }

                context("when notebook with that uuid exist in model") {
                    beforeEach {
                        let oldNotebook = Core.Notebook.Meta(uuid: "uuid", name: "old name")
                        e = e.evaluate(event: .didLoadNotebooks([secondNotebook, oldNotebook]))
                            .evaluate(event: event)
                    }

                    it("updates notebook with that uuid in model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [notebook, secondNotebook])
                        ))
                    }

                    it("has updateAllNotebooks effect") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotebooks([
                                Library.NotebookViewModel(title: "aname"),
                                Library.NotebookViewModel(title: "sname")
                            ])
                        ]))
                    }
                }

                context("when notebook with that uuid doesnt exist in model") {
                    beforeEach {
                        e = e.evaluate(event: .didLoadNotebooks([secondNotebook]))
                            .evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [secondNotebook])
                        ))
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }
            }

            context("when receiving deleteNotebook event") {
                let notebook = Core.Notebook.Meta(uuid: "uuid", name: "aname")
                let secondNotebook = Core.Notebook.Meta(uuid: "suuid", name: "sname")

                beforeEach {
                    event = .deleteNotebook(notebook)
                }

                context("when notebook with that uuid exist in model") {
                    beforeEach {
                        e = e.evaluate(event: .didLoadNotebooks([notebook, secondNotebook]))
                            .evaluate(event: event)
                    }

                    it("removes notebook from model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [secondNotebook])
                        ))
                    }

                    it("has deleteNotebook action") {
                        expect(e.actions).to(equalDiff([
                            .deleteNotebook(notebook)
                        ]))
                    }

                    it("has deleteNotebook effect") {
                        expect(e.effects).to(equalDiff([
                            .deleteNotebook(index: 0, notebooks: [Library.NotebookViewModel(title: "sname")])
                        ]))
                    }
                }

                context("when notebook with that uuid doesnt exist in model") {
                    beforeEach {
                        e = e.evaluate(event: .didLoadNotebooks([secondNotebook]))
                            .evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [secondNotebook])
                        ))
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }
            }

            context("when receiving didLoadNotebooks") {
                context("when notebook list is empty") {
                    beforeEach {
                        event = .didLoadNotebooks([])
                        e = e.evaluate(event: event)
                    }

                    it("has model with empty notebooks") {
                        expect(e.model).to(equalDiff(Library.Model(notebooks: [])))
                    }

                    it("has updateAllNotebooks effect with empty viewModels") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotebooks([])
                        ]))
                    }
                }

                context("when notebook list is not empty") {
                    let firstNotebook = Core.Notebook.Meta(uuid: "uuid1", name: "bcd")
                    let secondNotebook = Core.Notebook.Meta(uuid: "uuid2", name: "abc")
                    let thirdNotebook = Core.Notebook.Meta(uuid: "uuid3", name: "Cde")

                    beforeEach {
                        event = .didLoadNotebooks([firstNotebook, secondNotebook, thirdNotebook])
                        e = e.evaluate(event: event)
                    }

                    it("has model with sorted by name notebooks") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [secondNotebook, firstNotebook, thirdNotebook])
                        ))
                    }

                    it("has updateAllNotebooks effect with sorted viewModels") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotebooks([
                                Library.NotebookViewModel(title: "abc"),
                                Library.NotebookViewModel(title: "bcd"),
                                Library.NotebookViewModel(title: "Cde"),
                            ])
                        ]))
                    }
                }
            }

            context("when receiving didAddNotebook event") {
                let notebook = Core.Notebook.Meta(uuid: "uuid", name: "name")
                let anotherNotebook = Core.Notebook.Meta(uuid: "anotherUUID", name: "anotherName")
                let anotherNotebookViewModel = Library.NotebookViewModel(title: "anotherName")
                let model = Library.Model(notebooks: [notebook, anotherNotebook])

                beforeEach {
                    e = Library.Evaluator(notebooks: [notebook, anotherNotebook])
                }

                context("when successfully adds notebook") {
                    beforeEach {
                        event = .didAddNotebook(notebook, error: nil)
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
                        event = .didAddNotebook(notebook, error: underlyingError)
                    }

                    it("removes that notebook from model") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(equal([anotherNotebook]))
                    }

                    it("has updateAllNotebooks effect with view models without notebook") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateAllNotebooks([anotherNotebookViewModel])))
                    }

                    it("has showError action with message from error") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.showError(title: "Failed to add notebook", message: "message")))
                    }
                }
            }

            context("when receiving didDeleteNotebook event") {
                let notebook = Core.Notebook.Meta(uuid: "uuid", name: "name")
                let notebookViewModel = Library.NotebookViewModel(title: "name")
                let anotherNotebook = Core.Notebook.Meta(uuid: "anotherUUID", name: "anotherName")
                let anotherNotebookViewModel = Library.NotebookViewModel(title: "anotherName")
                let model = Library.Model(notebooks: [anotherNotebook])

                beforeEach {
                    e = Library.Evaluator(notebooks: [anotherNotebook])
                }

                context("when successfully deletes notebook") {
                    beforeEach {
                        event = .didDeleteNotebook(notebook, error: nil)
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
                        event = .didDeleteNotebook(notebook, error: error)
                    }

                    it("adds that notebook back to model") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(equal([anotherNotebook, notebook]))
                    }

                    it("has updateAllNotebooks effect with view models with notebook") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateAllNotebooks([anotherNotebookViewModel,
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
