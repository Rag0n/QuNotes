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
                    // TODO: replace by appropriate action
                    let model = UI.Library.Model(notebooks: [], editingNotebook: nil,
                                                 notebookMetas: [firstNotebookMeta, secondNotebookMeta])
                    e = UI.Library.Evaluator(effects: [], actions: [], model: model)
                    event = .addNotebook
                }

                it("creates notebook model with unique uuid") {
                    let firstAction = e.evaluate(event: event).actions[0]
                    let secondAction = e.evaluate(event: event).actions[0]
                    expect(firstAction).toNot(equal(secondAction))
                }

                it("updates model by adding notebook meta and sorting notebooks") {
                    UI.Library.Evaluator.uuidGenerator = { "newUUID" }
                    expect(e.evaluate(event: event).model.notebookMetas)
                        .to(equal([notebookMeta, firstNotebookMeta, secondNotebookMeta]))
                }

                it("has addNotebook action with notebook model") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equalExceptUUID(action: .addNotebook(notebook: notebookModel)))
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
                let model = UI.Library.Model(notebooks: [], editingNotebook: nil,
                                             notebookMetas: [firstNotebookMeta, secondNotebookMeta])

                beforeEach {
                    // TODO: replace by appropriate action
                    e = UI.Library.Evaluator(effects: [], actions: [], model: model)
                    event = .deleteNotebook(index: 0)
                }

                context("when notebook with that index exists") {
                    beforeEach {
                        event = .deleteNotebook(index: 0)
                    }

                    it("updates model by removing notebook meta") {
                        expect(e.evaluate(event: event).model.notebookMetas)
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
                let notebook = Notebook.notebookDummy()

                beforeEach {
                    e = e.evaluate(event: .didUpdateNotebooks(notebooks: [notebook]))
                    event = .selectNotebook(index: 0)
                }

                it("has showNotes action") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.showNotes(forNotebook: notebook)))
                }
            }

            context("when receiving updateNotebook event") {
                let notebook = Notebook.notebookDummy()

                beforeEach {
                    e = e.evaluate(event: .didUpdateNotebooks(notebooks: [notebook]))
                }

                context("when title in event is nil") {
                    beforeEach {
                        event = .updateNotebook(index: 0, title: nil)
                    }

                    it("has updateNotebook action with empty title") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.updateNotebook(notebook: notebook, title: "")))
                    }
                }

                context("when title in events is not nil") {
                    beforeEach {
                        event = .updateNotebook(index: 0, title: "title")
                    }

                    it("has updateNotebook action with title from event") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.updateNotebook(notebook: notebook, title: "title")))
                    }
                }
            }
        }

        describe("-evaluate:CoordinatorEvent") {
            var event: UI.Library.CoordinatorEvent!

            context("when receiving didAddNotebook2 event") {
                let notebook = Experimental.Notebook.Meta(uuid: "uuid", name: "name")
                let anotherNotebook = Experimental.Notebook.Meta(uuid: "anotherUUID", name: "anotherName")
                let anotherNotebookViewModel = UI.Library.NotebookViewModel(title: "anotherName", isEditable: false)
                let model = UI.Library.Model(notebooks: [], editingNotebook: nil,
                                             notebookMetas: [notebook, anotherNotebook])

                beforeEach {
                    // TODO: replace by appropriate action
                    e = UI.Library.Evaluator(effects: [], actions: [], model: model)
                }

                context("when successfully adds notebook") {
                    beforeEach {
                        event = .didAddNotebook2(notebook: notebook, error: nil)
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
                        event = .didAddNotebook2(notebook: notebook, error: underlyingError)
                    }

                    it("removes that notebook from model") {
                        expect(e.evaluate(event: event).model.notebookMetas)
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

            context("when receiving didUpdateNotebooks event") {
                let firstNotebook = Notebook(uuid: "uuid1", name: "bcd")
                let secondNotebook = Notebook(uuid: "uuid2", name: "abc")
                let thirdNotebook = Notebook(uuid: "uuid3", name: "Cde")
                let expectedViewModels = [
                    UI.Library.NotebookViewModel(title: "abc", isEditable: false),
                    UI.Library.NotebookViewModel(title: "bcd", isEditable: false),
                    UI.Library.NotebookViewModel(title: "Cde", isEditable: false),
                ]

                beforeEach {
                    event = .didUpdateNotebooks(notebooks: [firstNotebook, secondNotebook, thirdNotebook])
                }

                it("has model with sorted by name notebooks") {
                    expect(e.evaluate(event: event).model.notebooks)
                        .to(equal([secondNotebook, firstNotebook, thirdNotebook]))
                }

                it("has updateAllNotebooks effect with correct order of ViewModels") {
                    expect(e.evaluate(event: event).effects[0])
                        .to(equal(.updateAllNotebooks(notebooks: expectedViewModels)))
                }

                context("when there's editing notebook") {
                    beforeEach {
                        e = e.evaluate(event: .didUpdateNotebooks(notebooks: [firstNotebook, secondNotebook]))
                            .evaluate(event: .didAddNotebook(result: Result(value: thirdNotebook)))
                    }

                    it("has model without editing notebook") {
                        expect(e.evaluate(event: event).model.editingNotebook)
                            .to(beNil())
                    }
                }
            }

            context("when receiving didAddNotebook event") {
                context("when successfully adds notebook") {
                    let firstNotebook = Notebook(uuid: "uuid1", name: "abc")
                    let secondNotebook = Notebook(uuid: "uuid2", name: "cde")
                    let addedNotebook = Notebook(uuid: "uuid3", name: "bcd")
                    let expectedViewModels = [
                        UI.Library.NotebookViewModel(title: "abc", isEditable: false),
                        UI.Library.NotebookViewModel(title: "bcd", isEditable: true),
                        UI.Library.NotebookViewModel(title: "cde", isEditable: false)
                    ]

                    beforeEach {
                        e = e.evaluate(event: .didUpdateNotebooks(notebooks: [firstNotebook, secondNotebook]))
                        event = .didAddNotebook(result: Result(addedNotebook))
                    }

                    it("has model with editingNotebook equal to new notebook") {
                        expect(e.evaluate(event: event).model.editingNotebook)
                            .to(equal(addedNotebook))
                    }

                    it("has model with appended notebook and correct sorting") {
                        expect(e.evaluate(event: event).model.notebooks)
                            .to(equal([firstNotebook, addedNotebook, secondNotebook]))
                    }

                    it("has addNotebook effect with correct viewModels and index") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.addNotebook(index: 1, notebooks: expectedViewModels)))
                    }
                }

                context("when fails to add notebook") {
                    beforeEach {
                        event = .didAddNotebook(result: Result(error: error))
                    }

                    it("has updateAllNotebooks effect with notebooks from current model") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateAllNotebooks(notebooks: [])))
                    }

                    it("has showError action") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.showError(title: "Failed to add notebook", message: "message")))
                    }

                    context("when there's editing notebook") {
                        beforeEach {
                            e = e.evaluate(event: .didAddNotebook(result: Result(Notebook.notebookDummy())))
                        }

                        it("has model without editing notebook") {
                            expect(e.evaluate(event: event).model.editingNotebook)
                                .to(beNil())
                        }
                    }
                }
            }

            context("when receiving didDeleteNotebook event") {
                let notebook = Experimental.Notebook.Meta(uuid: "uuid", name: "name")
                let notebookViewModel = UI.Library.NotebookViewModel(title: "name", isEditable: false)
                let anotherNotebook = Experimental.Notebook.Meta(uuid: "anotherUUID", name: "anotherName")
                let anotherNotebookViewModel = UI.Library.NotebookViewModel(title: "anotherName", isEditable: false)
                let model = UI.Library.Model(notebooks: [], editingNotebook: nil,
                                             notebookMetas: [anotherNotebook])

                beforeEach {
                    // TODO: replace by appropriate action
                    e = UI.Library.Evaluator(effects: [], actions: [], model: model)
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
                        expect(e.evaluate(event: event).model.notebookMetas)
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

            context("when receiving didUpdateNotebook event") {
                context("when successfully updates notebook") {
                    let firstNotebook = Notebook(uuid: "uuid1", name: "bcd")
                    let secondNotebook = Notebook(uuid: "uuid2", name: "oldName")
                    let expectedViewModels = [
                        UI.Library.NotebookViewModel(title: "abc", isEditable: false),
                        UI.Library.NotebookViewModel(title: "bcd", isEditable: false)
                    ]

                    beforeEach {
                        e = e.evaluate(event: .didUpdateNotebooks(notebooks: [firstNotebook, secondNotebook]))
                        event = .didUpdateNotebook(result: Result(Notebook(uuid: "uuid2", name: "abc")))
                    }

                    it("has updateAllNotebooks effect with updated notebook") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateAllNotebooks(notebooks: expectedViewModels)))
                    }

                    context("when there's editing notebook") {
                        beforeEach {
                            e = e.evaluate(event: .didUpdateNotebooks(notebooks: [firstNotebook]))
                                .evaluate(event: .didAddNotebook(result: Result(secondNotebook)))
                        }

                        it("has model without editing notebook") {
                            expect(e.evaluate(event: event).model.editingNotebook)
                                .to(beNil())
                        }
                    }
                }

                context("when fails to update notebook") {
                    beforeEach {
                        event = .didUpdateNotebook(result: Result(error: error))
                    }

                    it("has updateAllNotebooks effect with notebooks from current model") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateAllNotebooks(notebooks: [])))
                    }

                    it("has showError action") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.showError(title: "Failed to update notebook", message: "message")))
                    }

                    context("when there's editing notebook") {
                        beforeEach {
                            e = e.evaluate(event: .didAddNotebook(result: Result(Notebook.notebookDummy())))
                        }

                        it("has model without editing notebook") {
                            expect(e.evaluate(event: event).model.editingNotebook)
                                .to(beNil())
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Custom matchers

func equalExceptUUID(action: UI.Library.Action) -> Predicate<UI.Library.Action> {
    return Predicate { (actualExpression: Expression<UI.Library.Action>) throws -> PredicateResult in
        guard case .addNotebook(let notebook)? = try actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: ExpectationMessage.fail("Received action is not addNotebook action")
            )
        }
        guard case .addNotebook(let expectedNotebook) = action else {
            return PredicateResult(
                status: .fail,
                message: ExpectationMessage.fail("Expected action is note addNotebook action")
            )
        }

        var details = ""
        let isNameEqual = notebook.name == expectedNotebook.name
        details = isNameEqual ? details : details.appending("Name is not equal: expected \(expectedNotebook.name), got \(notebook.name) ")
        let areNotesEqual = notebook.notes == expectedNotebook.notes
        details = areNotesEqual ? details : details.appending("Notes are not equal: expected \(expectedNotebook.notes), got \(notebook.notes) ")


        var msg = ExpectationMessage.expectedTo("receive .addNotebook action with equal notebooks: ")
        msg = details.isEmpty ? msg : msg.appended(details: details)

        return PredicateResult(
            bool: isNameEqual && areNotesEqual,
            message: msg
        )
    }
}
