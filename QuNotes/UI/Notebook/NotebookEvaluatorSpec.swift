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
        let notebook = Notebook.Meta(uuid: "uuid", name: "name")
        var e: UI.Notebook.Evaluator!
        let underlyingError = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])
        let error = AnyError(underlyingError)

        beforeEach {
            e = UI.Notebook.Evaluator(notebook: notebook)
        }

        describe("-evaluate:CoordinatorEvent") {
            var event: UI.Notebook.CoordinatorEvent!

            context("when receiving didLoadNotes") {
                context("when note list is empty") {
                    beforeEach {
                        event = .didLoadNotes(notes: [])
                        e = e.evaluate(event: event)
                    }

                    it("has model with empty notebooks") {
                        expect(e.model).to(equalDiff(UI.Notebook.Model(notebook: notebook, notes: [])))
                    }

                    it("has updateAllNotebooks effect with empty viewModels") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotes(notes: [])
                        ]))
                    }
                }

                context("when notebook list is not empty") {
                    let firstNote = Note.Meta(uuid: "fU", title: "b", tags: ["t"], updated_at: 1, created_at: 1)
                    let secondNote = Note.Meta(uuid: "sU", title: "a", tags: ["t"], updated_at: 2, created_at: 2)
                    let thirdNote = Note.Meta(uuid: "tU", title: "C", tags: ["t"], updated_at: 3, created_at: 3)

                    beforeEach {
                        event = .didLoadNotes(notes: [firstNote, secondNote, thirdNote])
                        e = e.evaluate(event: event)
                    }

                    it("has model with sorted by name notebooks") {
                        expect(e.model).to(equalDiff(
                            UI.Notebook.Model(notebook: notebook, notes: [secondNote, firstNote, thirdNote])
                        ))
                    }

                    it("has updateAllNotebooks effect with sorted viewModels") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotes(notes: ["a", "b", "C"])
                        ]))
                    }
                }
            }
        }
    }
}

//        describe("-evaluate:ViewControllerEvent") {
//            var event: UI.Notebook.ViewControllerEvent!
//
//            context("when receiving didLoad event") {
//                beforeEach {
//                    event = .didLoad
//                }
//
//                it("has updateTitle effect") {
//                    expect(e.evaluate(event: event).effects[0])
//                        .to(equal(.updateTitle(title: "name")))
//                }
//            }
//
//            context("when receiving addNote event") {
//                beforeEach {
//                    event = .addNote
//                }
//
//                it("has addNote action") {
//                    expect(e.evaluate(event: event).actions[0])
//                        .to(equal(UI.Notebook.Action.addNote))
//                }
//            }
//
//            context("when receiving selectNote event") {
//                let note = UseCase.Note.noteDummy()
//
//                beforeEach {
//                    event = .selectNote(index: 0)
//                    e = e.evaluate(event: .didUpdateNotes(notes: [note]))
//                }
//
//                it("has showNote action") {
//                    expect(e.evaluate(event: event).actions[0])
//                        .to(equal(.showNote(note: note, isNewNote: false)))
//                }
//            }
//
//            context("when receiving deleteNote event") {
//                let note = UseCase.Note.noteDummy()
//
//                beforeEach {
//                    event = .deleteNote(index: 0)
//                    e = e.evaluate(event: .didUpdateNotes(notes: [note]))
//                }
//
//                it("has deleteNote action") {
//                    expect(e.evaluate(event: event).actions[0])
//                        .to(equal(.deleteNote(note: note)))
//                }
//            }
//
//            context("when receiving deleteNotebook event") {
//                beforeEach {
//                    event = .deleteNotebook
//                }
//
//                it("has deleteNotebook action") {
//                    expect(e.evaluate(event: event).actions[0])
//                        .to(equal(.deleteNotebook(notebook: notebook)))
//                }
//            }
//
//            context("when receiving filterNotes event") {
//                let firstNote = UseCase.Note.noteDummy(withTitle: "AB")
//                let secondNote = UseCase.Note.noteDummy(withTitle: "ab")
//                let thirdNote = UseCase.Note.noteDummy(withTitle: "g")
//
//                beforeEach {
//                    e = e.evaluate(event: .didUpdateNotes(notes: [firstNote, secondNote, thirdNote]))
//                }
//
//                context("when filter is nil") {
//                    beforeEach {
//                        event = .filterNotes(filter: nil)
//                    }
//
//                    it("has updateAllNotes effect with all note's titles") {
//                        expect(e.evaluate(event: event).effects[0])
//                            .to(equal(.updateAllNotes(notes: ["AB", "ab", "g"])))
//                    }
//                }
//
//                context("when filter is not nil") {
//                    beforeEach {
//                        event = .filterNotes(filter: "aB")
//                    }
//
//                    it("has updateAllNotes effect with only titles containing filter in any register") {
//                        expect(e.evaluate(event: event).effects[0])
//                            .to(equal(.updateAllNotes(notes: ["AB", "ab"])))
//                    }
//                }
//            }
//
//            context("when receiving didStartToEditTitle event") {
//                beforeEach {
//                    event = .didStartToEditTitle
//                }
//
//                it("has hideBackButton effect") {
//                    expect(e.evaluate(event: event).effects[0])
//                        .to(equal(UI.Notebook.ViewControllerEffect.hideBackButton))
//                }
//            }
//
//            context("when receiving didFinishToEditTitle event") {
//                beforeEach {
//                    event = .didFinishToEditTitle(newTitle: nil)
//                }
//
//                it("has showBackButton effect") {
//                    expect(e.evaluate(event: event).effects[0])
//                        .to(equal(UI.Notebook.ViewControllerEffect.showBackButton))
//                }
//
//                context("when title is nil") {
//                    it("has updateNotebook action with empty title") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(.updateNotebook(notebook: notebook, title: "")))
//                    }
//                }
//
//                context("when title is not nil") {
//                    beforeEach {
//                        event = .didFinishToEditTitle(newTitle: "new title")
//                    }
//
//                    it("has updateNotebook action with title from event") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(.updateNotebook(notebook: notebook, title: "new title")))
//                    }
//                }
//            }
//        }

//
//            context("when receiving didUpdateNotes event") {
//                let firstNote = UseCase.Note.noteDummy(withTitle: "Bcd")
//                let secondNote = UseCase.Note.noteDummy(withTitle: "abc")
//                let thirdNote = UseCase.Note.noteDummy(withTitle: "cde")
//                let expectedViewModels = [
//                    "abc",
//                    "Bcd",
//                    "cde"
//                ]
//
//                beforeEach {
//                    event = .didUpdateNotes(notes: [firstNote, secondNote, thirdNote])
//                }
//
//                it("has model with sorted by name notes") {
//                    expect(e.evaluate(event: event).model.notes)
//                        .to(equal([secondNote, firstNote, thirdNote]))
//                }
//
//                it("has updateAllNotes effect with correct order of ViewModels") {
//                    expect(e.evaluate(event: event).effects[0])
//                        .to(equal(.updateAllNotes(notes: expectedViewModels)))
//                }
//            }
//
//            context("when receiving didAddNote event") {
//                context("when successfully adds note") {
//                    let firstNote = UseCase.Note.noteDummy(withTitle: "abc")
//                    let secondNote = UseCase.Note.noteDummy(withTitle: "cde")
//                    let addedNote = UseCase.Note.noteDummy(withTitle: "bcd")
//
//                    beforeEach {
//                        e = e.evaluate(event: .didUpdateNotes(notes: [firstNote, secondNote]))
//                        event = .didAddNote(result: Result(addedNote))
//                    }
//
//                    it("has model with appended note and correct sorting") {
//                        expect(e.evaluate(event: event).model.notes)
//                            .to(equal([firstNote, addedNote, secondNote]))
//                    }
//
//                    it("has showNote action with added note") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(.showNote(note: addedNote, isNewNote: true)))
//                    }
//                }
//
//                context("when fails to add note") {
//                    beforeEach {
//                        event = .didAddNote(result: Result(error: error))
//                    }
//
//                    it("has showError action") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(.showError(title: "Failed to add note", message: "message")))
//                    }
//                }
//            }
//
//            context("when receiving didDeleteNote event") {
//                let firstNote = UseCase.Note.noteDummy(withTitle: "abc")
//                let secondNote = UseCase.Note.noteDummy(withTitle: "cde")
//
//                context("when successfuly deletes note") {
//                    beforeEach {
//                        e = e.evaluate(event: .didUpdateNotes(notes: [firstNote, secondNote]))
//                        event = .didDeleteNote(result: Result(secondNote))
//                    }
//
//                    it("has model without removed note") {
//                        expect(e.evaluate(event: event).model.notes)
//                            .to(equal([firstNote]))
//                    }
//
//                    it("has deleteNote effect with correct index and viewModels") {
//                        expect(e.evaluate(event: event).effects[0])
//                            .to(equal(.deleteNote(index: 1, notes: ["abc"])))
//                    }
//                }
//
//                context("when fails to delete note") {
//                    beforeEach {
//                        e = e.evaluate(event: .didUpdateNotes(notes: [firstNote, secondNote]))
//                        event = .didDeleteNote(result: Result(error: error))
//                    }
//
//                    it("has showError action") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(.showError(title: "Failed to delete notebook", message: "message")))
//                    }
//
//                    it("has updateAllNotes effect") {
//                        expect(e.evaluate(event: event).effects[0])
//                            .to(equal(.updateAllNotes(notes: ["abc", "cde"])))
//                    }
//                }
//            }
//
//            context("when receiving didUpdateNotebook event") {
//                let notebook = UseCase.Notebook.notebookDummy(withUUID: "uuid", name: "new name")
//
//                context("when successfully updates notebook") {
//                    beforeEach {
//                        event = .didUpdateNotebook(result: Result(notebook))
//                    }
//
//                    it("has model with updated notebook") {
//                        expect(e.evaluate(event: event).model.notebook)
//                            .to(equal(notebook))
//                    }
//
//                    it("has updateTitle effect with updated notebook name") {
//                        expect(e.evaluate(event: event).effects[0])
//                            .to(equal(.updateTitle(title: "new name")))
//                    }
//                }
//
//                context("when fails to update notebook") {
//                    beforeEach {
//                        event = .didUpdateNotebook(result: Result(error: error))
//                    }
//
//                    it("has showError action") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(.showError(title: "Failed to update notebook's title", message: "message")))
//                    }
//
//                    it("has updateTitle effect with old notebook name") {
//                        expect(e.evaluate(event: event).effects[0])
//                            .to(equal(.updateTitle(title: "name")))
//                    }
//                }
//            }
//
//            context("when receiving didDeleteNotebook event") {
//                context("when successfully deletes notebook") {
//                    beforeEach {
//                        event = .didDeleteNotebook(error: nil)
//                    }
//
//                    it("has finish action") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(UI.Notebook.Action.finish))
//                    }
//                }
//
//                context("when fails to delete notebook") {
//                    beforeEach {
//                        event = .didDeleteNotebook(error: error)
//                    }
//
//                    it("has showError action") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(.showError(title: "Failed to delete notebook", message: "message")))
//                    }
//                }
//            }
//        }
//    }
//}

