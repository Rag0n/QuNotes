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

        beforeEach {
            e = Library.Evaluator()
        }

        describe("-evaluating:ViewEvent") {
            var event: Library.ViewEvent!

            context("when receiving addNotebook event") {
                let notebook = Dummy.notebook(withName: "", uuid: "newUUID")
                let firstNotebook = Dummy.notebook(withName: "abc")
                let secondNotebook = Dummy.notebook(withName: "cde")

                beforeEach {
                    e = Library.Evaluator(notebooks: [firstNotebook, secondNotebook])
                    event = .addNotebook
                    e.generateUUID = { "newUUID" }
                    e = e.evaluating(event: event)
                }

                it("creates notebook model with unique uuid") {
                    let firstAction = e.evaluating(event: event).actions[0]
                    let secondAction = e.evaluating(event: event).actions[0]
                    expect(firstAction).toNot(equal(secondAction))
                }

                it("updates model by adding notebook meta and sorting notebooks") {
                    expect(e.model).to(equalDiff(
                        Library.Model(notebooks: [notebook, firstNotebook, secondNotebook])
                    ))
                }

                it("has addNotebook action with notebook model") {
                    e.generateUUID = { "newUUID" }
                    expect(e.actions).to(equalDiff([
                        .addNotebook(notebook)
                    ]))
                }

                it("has addNotebook effect with correct viewModels and index") {
                    expect(e.effects).to(equalDiff([
                        .addNotebook(index: 0, notebooks: [Library.NotebookViewModel(title: ""),
                                                           Library.NotebookViewModel(title: "abc"),
                                                           Library.NotebookViewModel(title: "cde")])
                    ]))
                }
            }

            context("when receiving deleteNotebook event") {
                let firstNotebook = Dummy.notebook(withName: "a")
                let secondNotebook = Dummy.notebook(withName: "c")
                let model = Library.Model(notebooks: [firstNotebook, secondNotebook])

                beforeEach {
                    e = Library.Evaluator(notebooks: [firstNotebook, secondNotebook])
                }

                context("when notebook with that index exists") {
                    beforeEach {
                        event = .deleteNotebook(index: 1)
                        e = e.evaluating(event: event)
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
                            .deleteNotebook(index: 1, notebooks: [Library.NotebookViewModel(title: "a")])
                        ]))
                    }
                }

                context("when notebook with that index doesnt exist") {
                    beforeEach {
                        event = .deleteNotebook(index: 3)
                        e = e.evaluating(event: event)
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
                    e = e.evaluating(event: event)
                }

                it("has showNotebook action") {
                    expect(e.actions).to(equalDiff([
                        .showNotebook(Core.Notebook.Meta(uuid: "uuid", name: "name"), isNew: false)
                    ]))
                }
            }
        }

        describe("-evaluating:CoordinatorEvent") {
            var event: Library.CoordinatorEvent!

            context("when receiving updateNotebook event") {
                let notebook = Dummy.notebook(withName: "aname")
                let secondNotebook = Dummy.notebook(withName: "sname")

                beforeEach {
                    event = .updateNotebook(notebook)
                }

                context("when notebook with that uuid exist in model") {
                    beforeEach {
                        let oldNotebook = Core.Notebook.Meta(uuid: notebook.uuid, name: "old name")
                        e = e.evaluating(event: .didLoadNotebooks([secondNotebook, oldNotebook]))
                            .evaluating(event: event)
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
                        e = e.evaluating(event: .didLoadNotebooks([secondNotebook]))
                            .evaluating(event: event)
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
                let notebook = Dummy.notebook(withName: "aname")
                let secondNotebook = Dummy.notebook(withName: "sname")

                beforeEach {
                    event = .deleteNotebook(notebook)
                }

                context("when notebook with that uuid exist in model") {
                    beforeEach {
                        e = e.evaluating(event: .didLoadNotebooks([notebook, secondNotebook]))
                            .evaluating(event: event)
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
                        e = e.evaluating(event: .didLoadNotebooks([secondNotebook]))
                            .evaluating(event: event)
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
                        e = e.evaluating(event: event)
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
                    let firstNotebook = Dummy.notebook(withName: "bcd")
                    let secondNotebook = Dummy.notebook(withName: "abc")
                    let thirdNotebook = Dummy.notebook(withName: "Cde")

                    beforeEach {
                        event = .didLoadNotebooks([firstNotebook, secondNotebook, thirdNotebook])
                        e = e.evaluating(event: event)
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
                let notebook = Dummy.notebook(withName: "name")
                let anotherNotebook = Dummy.notebook(withName: "anotherName")
                let model = Library.Model(notebooks: [notebook, anotherNotebook])

                beforeEach {
                    e = Library.Evaluator(notebooks: [notebook, anotherNotebook])
                }

                context("when successfully adds notebook") {
                    beforeEach {
                        event = .didAddNotebook(notebook, error: nil)
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("has showNotebook action") {
                        expect(e.actions).to(equalDiff([
                            .showNotebook(notebook, isNew: true)
                        ]))
                    }

                    it("hasnt got any effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }

                context("when failed to add notebook") {
                    beforeEach {
                        event = .didAddNotebook(notebook, error: Dummy.error)
                        e = e.evaluating(event: event)
                    }

                    it("removes that notebook from model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [anotherNotebook])
                        ))
                    }

                    it("has updateAllNotebooks effect with view models without notebook") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotebooks([Library.NotebookViewModel(title: "anotherName")])
                        ]))
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.addNotebook, reason: "message")
                        ]))
                    }
                }
            }

            context("when receiving didDeleteNotebook event") {
                let notebook = Dummy.notebook(withName: "name")
                let anotherNotebook = Dummy.notebook(withName: "anotherName")
                let model = Library.Model(notebooks: [anotherNotebook])

                beforeEach {
                    e = Library.Evaluator(notebooks: [anotherNotebook])
                }

                context("when successfully deletes notebook") {
                    beforeEach {
                        event = .didDeleteNotebook(notebook, error: nil)
                        e = e.evaluating(event: event)
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

                context("when fails to delete notebook") {
                    beforeEach {
                        event = .didDeleteNotebook(notebook, error: Dummy.anyError)
                        e = e.evaluating(event: event)
                    }

                    it("adds that notebook back to model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [anotherNotebook, notebook])
                        ))
                    }

                    it("has updateAllNotebooks effect with view models with notebook") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotebooks([Library.NotebookViewModel(title: "anotherName"),
                                                 Library.NotebookViewModel(title: "name")])
                        ]))
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.deleteNotebook, reason: "message")
                        ]))
                    }
                }
            }
        }
    }
}

private enum Dummy {
    static let error = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
    static let anyError = AnyError(error)
    static let errorMessage = "message"
    static let filter = ""

    static func notebook(withName name: String, uuid: String = UUID().uuidString) -> Core.Notebook.Meta {
        return Core.Notebook.Meta(uuid: uuid, name: name)
    }
}
