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
        let underlyingError = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "localized message"])
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
                    expect(e.evaluate(event: event).actions).to(contain(.addNotebook))
                }
            }

            context("when receiving deleteNotebook event") {
                let notebook = Notebook.notebookDummy()

                beforeEach {
                    e = e.evaluate(event: .didUpdateNotebooks(notebooks: [notebook]))
                    event = .deleteNotebook(index: 0)
                }

                it("has deleteNotebook action") {
                    expect(e.evaluate(event: event).actions).to(contain(.deleteNotebook(notebook: notebook)))
                }
            }

            context("when receiving selectNotebook event") {
                let notebook = Notebook.notebookDummy()

                beforeEach {
                    e = e.evaluate(event: .didUpdateNotebooks(notebooks: [notebook]))
                    event = .selectNotebook(index: 0)
                }

                it("has showNotes action") {
                    expect(e.evaluate(event: event).actions).to(contain(.showNotes(forNotebook: notebook)))
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
                        expect(e.evaluate(event: event).actions).to(contain(.updateNotebook(notebook: notebook, title: "")))
                    }
                }

                context("when title in events is not nil") {
                    beforeEach {
                        event = .updateNotebook(index: 0, title: "title")
                    }

                    it("has updateNotebook action with title from event") {
                        expect(e.evaluate(event: event).actions).to(contain(.updateNotebook(notebook: notebook, title: "title")))
                    }
                }
            }
        }

        describe("-evaluate:CoordinatorEvent:") {
        }
    }
}
