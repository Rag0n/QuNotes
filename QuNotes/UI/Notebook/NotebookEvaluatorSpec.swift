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

            context("when receiving didLoad event") {
                beforeEach {
                    event = .didLoad
                }

                it("contains updateTitle effect") {
                    expect(e.evaluate(event: event).effects).to(contain(.updateTitle(title: "name")))
                }
            }

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
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.updateAllNotes(notes: ["AB", "ab", "g"])))
                    }
                }

                context("when filter is not nil") {
                    beforeEach {
                        event = .filterNotes(filter: "aB")
                    }

                    it("contains updateAllNotes effect with only titles containing filter in any register") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.updateAllNotes(notes: ["AB", "ab"])))
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
                        expect(e.evaluate(event: event).actions)
                            .to(contain(.updateNotebook(notebook: notebook, title: "")))
                    }
                }

                context("when title is not nil") {
                    beforeEach {
                        event = .didFinishToEditTitle(newTitle: "new title")
                    }

                    it("contains updateNotebook action with title from event") {
                        expect(e.evaluate(event: event).actions)
                            .to(contain(.updateNotebook(notebook: notebook, title: "new title")))
                    }
                }
            }
        }

        describe("-evaluate:CoordinatorEvent:") {
            var event: UI.Notebook.CoordinatorEvent!

            context("when receiving didUpdateNotes event") {
                let firstNote = Note.noteDummy(withTitle: "Bcd")
                let secondNote = Note.noteDummy(withTitle: "abc")
                let thirdNote = Note.noteDummy(withTitle: "cde")
                let expectedViewModels = [
                    "abc",
                    "Bcd",
                    "cde"
                ]

                beforeEach {
                    event = .didUpdateNotes(notes: [firstNote, secondNote, thirdNote])
                }

                it("has model with sorted by name notes") {
                    expect(e.evaluate(event: event).model.notes)
                        .to(equal([secondNote, firstNote, thirdNote]))
                }

                it("has updateAllNotes effect with correct order of ViewModels") {
                    expect(e.evaluate(event: event).effects)
                        .to(contain(.updateAllNotes(notes: expectedViewModels)))
                }
            }

            context("when receiving didAddNote event") {
                context("when result is note") {
                    let firstNote = Note.noteDummy(withTitle: "abc")
                    let secondNote = Note.noteDummy(withTitle: "cde")
                    let addedNote = Note.noteDummy(withTitle: "bcd")

                    beforeEach {
                        e = e.evaluate(event: .didUpdateNotes(notes: [firstNote, secondNote]))
                        event = .didAddNote(result: Result(addedNote))
                    }

                    it("has model with appended note and correct sorting") {
                        expect(e.evaluate(event: event).model.notes)
                            .to(equal([firstNote, addedNote, secondNote]))
                    }

                    it("has showNote action with added note") {
                        expect(e.evaluate(event: event).actions)
                            .to(contain(.showNote(note: addedNote)))
                    }
                }

                context("when result is error") {
                    beforeEach {
                        event = .didAddNote(result: Result(error: error))
                    }

                    it("contains showError effect") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.showError(error: "Failed to add note", message: "localized message")))
                    }
                }
            }

            context("when receiving didDeleteNote event") {
                let firstNote = Note.noteDummy(withTitle: "abc")
                let secondNote = Note.noteDummy(withTitle: "cde")

                context("when result is note") {
                    beforeEach {
                        e = e.evaluate(event: .didUpdateNotes(notes: [firstNote, secondNote]))
                        event = .didDeleteNote(result: Result(secondNote))
                    }

                    it("has model without removed note") {
                        expect(e.evaluate(event: event).model.notes)
                            .to(equal([firstNote]))
                    }

                    it("has deleteNote effect with correct index and viewModels") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.deleteNote(index: 1, notes: ["abc"])))
                    }
                }

                context("when result is error") {
                    beforeEach {
                        e = e.evaluate(event: .didUpdateNotes(notes: [firstNote, secondNote]))
                        event = .didDeleteNote(result: Result(error: error))
                    }

                    it("contains showError effect") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.showError(error: "Failed to delete notebook", message: "localized message")))
                    }

                    it("contains updateAllNotes effect") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.updateAllNotes(notes: ["abc", "cde"])))
                    }
                }
            }

            context("when receiving didUpdateNotebook event") {
                let notebook = Notebook.notebookDummy(withUUID: "uuid", name: "new name")

                context("when result is notebook") {
                    beforeEach {
                        event = .didUpdateNotebook(result: Result(notebook))
                    }

                    it("has model with updated notebook") {
                        expect(e.evaluate(event: event).model.notebook)
                            .to(equal(notebook))
                    }

                    it("constains updateTitle effect with updated notebook name") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.updateTitle(title: "new name")))
                    }
                }

                context("when result is error") {
                    beforeEach {
                        event = .didUpdateNotebook(result: Result(error: error))
                    }

                    it("contains showError effect") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.showError(error: "Failed to update notebook's title", message: "localized message")))
                    }

                    it("constains updateTitle effect with old notebook name") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.updateTitle(title: "name")))
                    }
                }
            }

            context("when receiving didDeleteNotebook event") {
                context("when error is nil") {
                    beforeEach {
                        event = .didDeleteNotebook(error: nil)
                    }

                    it("constains finish action") {
                        expect(e.evaluate(event: event).actions)
                            .to(contain(.finish))
                    }
                }

                context("when error is not nil") {
                    beforeEach {
                        event = .didDeleteNotebook(error: error)
                    }

                    it("contains showError effect") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.showError(error: "Failed to delete notebook", message: "localized message")))
                    }
                }
            }
        }
    }
}
