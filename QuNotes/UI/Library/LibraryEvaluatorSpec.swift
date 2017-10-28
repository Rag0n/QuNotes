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

        describe("-evaluate:ViewControllerEvent:") {
            var event: UI.Library.ViewControllerEvent!

            context("when receiving addNotebook event") {
                beforeEach {
                    event = .addNotebook
                }

                it("has addNotebook action") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(UI.Library.Action.addNotebook))
                }
            }

            context("when receiving deleteNotebook event") {
                let notebook = Notebook.notebookDummy()

                beforeEach {
                    e = e.evaluate(event: .didUpdateNotebooks(notebooks: [notebook]))
                    event = .deleteNotebook(index: 0)
                }

                it("has deleteNotebook action") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.deleteNotebook(notebook: notebook)))
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

        describe("-evaluate:CoordinatorEvent:") {
            var event: UI.Library.CoordinatorEvent!

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
                context("when successfully deletes notebook") {
                    let firstNotebook = Notebook(uuid: "uuid1", name: "abc")
                    let secondNotebook = Notebook(uuid: "uuid2", name: "cde")
                    let expectedViewModels = [
                        UI.Library.NotebookViewModel(title: "abc", isEditable: false)
                    ]

                    beforeEach {
                        e = e.evaluate(event: .didUpdateNotebooks(notebooks: [firstNotebook, secondNotebook]))
                        event = .didDeleteNotebook(result: Result(secondNotebook))
                    }

                    it("has deleteNotebook effect without removed notebook") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.deleteNotebook(index: 1, notebooks: expectedViewModels)))
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

                context("when fails to delete notebook") {
                    beforeEach {
                        event = .didDeleteNotebook(result: Result(error: error))
                    }

                    it("has updateAllNotebooks effect with notebooks from current model") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateAllNotebooks(notebooks: [])))
                    }

                    it("has showError action") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.showError(title: "Failed to delete notebook", message: "message")))
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
