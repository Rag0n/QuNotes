//
//  NotebookEvaluatorSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 19.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NotebookEvaluatorSpec: QuickSpec {
    override func spec() {
        let notebook = Notebook(uuid: "uuid", name: "name")
        var e: UI.Notebook.Evaluator!
        let underlyingError = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "localized message"])
        let error = AnyError(underlyingError)

        beforeEach {
            e = UI.Notebook.Evaluator(withNotebook: notebook)
        }

        describe("-evaluate:ViewControllerEvent:") {
            var event: UI.Notebook.ViewControllerEvent!

            context("when receiving addNote event") {
                beforeEach {
                    event = .addNote
                }

                it("contains addNote action") {
                    expect(e.evaluate(event: event).actions).to(contain(.addNote))
                }
            }

            context("when receiving selectNote event") {
                let note = Note.noteDummy()

                beforeEach {
                    event = .selectNote(index: 0)
                    e = e.evaluate(event: .didUpdateNotes(notes: [note]))
                }

                it("contains showNote action") {
                    expect(e.evaluate(event: event).actions).to(contain(.showNote(note: note)))
                }
            }

            context("when receiving deleteNote event") {
                let note = Note.noteDummy()

                beforeEach {
                    event = .deleteNote(index: 0)
                    e = e.evaluate(event: .didUpdateNotes(notes: [note]))
                }

                it("contains deleteNote action") {
                    expect(e.evaluate(event: event).actions).to(contain(.deleteNote(note: note)))
                }
            }

            context("when receiving deleteNotebook event") {
                beforeEach {
                    event = .deleteNotebook
                }

                it("contains deleteNotebook action") {
                    expect(e.evaluate(event: event).actions).to(contain(.deleteNotebook(notebook: notebook)))
                }
            }

            context("when receiving filterNotes event") {
                let firstNote = Note.noteDummy(withTitle: "AB")
                let secondNote = Note.noteDummy(withTitle: "ab")
                let thirdNote = Note.noteDummy(withTitle: "g")

                beforeEach {
                    e = e.evaluate(event: .didUpdateNotes(notes: [firstNote, secondNote, thirdNote]))
                }

                context("when filter is nil") {
                    beforeEach {
                        event = .filterNotes(filter: nil)
                    }

                    it("contains updateAllNotes effect with all note's titles") {
                        expect(e.evaluate(event: event).effects).to(contain(.updateAllNotes(notes: ["AB", "ab", "g"])))
                    }
                }

                context("when filter is not nil") {
                    beforeEach {
                        event = .filterNotes(filter: "aB")
                    }

                    it("contains updateAllNotes effect with only titles containing filter in any register") {
                        expect(e.evaluate(event: event).effects).to(contain(.updateAllNotes(notes: ["AB", "ab"])))
                    }
                }
            }

            context("when receiving didStartToEditTitle event") {
                beforeEach {
                    event = .didStartToEditTitle
                }

                it("contains hideBackButton effect") {
                    expect(e.evaluate(event: event).effects).to(contain(.hideBackButton))
                }
            }

            context("when receiving didFinishToEditTitle event") {
                beforeEach {
                    event = .didFinishToEditTitle(newTitle: nil)
                }

                it("contains showBackButton effect") {
                    expect(e.evaluate(event: event).effects).to(contain(.showBackButton))
                }

                context("when title is nil") {
                    it("contains updateNotebook action with empty title") {
                        expect(e.evaluate(event: event).actions).to(contain(.updateNotebook(notebook: notebook, title: "")))
                    }
                }

                context("when title is not nil") {
                    beforeEach {
                        event = .didFinishToEditTitle(newTitle: "new title")
                    }

                    it("contains updateNotebook action with title from event") {
                        expect(e.evaluate(event: event).actions).to(contain(.updateNotebook(notebook: notebook, title: "new title")))
                    }
                }
            }
        }

        describe("-evaluate:CoordinatorEvent:") {
        }
    }
}
