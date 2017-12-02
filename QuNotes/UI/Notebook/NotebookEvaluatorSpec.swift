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

        describe("-evaluate:ViewEvent") {
            var event: UI.Notebook.ViewEvent!

            context("when receiving didLoad event") {
                beforeEach {
                    event = .didLoad
                    e = e.evaluate(event: event)
                }

                it("has updateTitle effect") {
                    expect(e.effects).to(equalDiff([
                        .updateTitle(title: "name")
                    ]))
                }
            }

            context("when receiving addNote event") {

                let anotherNote = Note.Meta(uuid: "aU", title: "aT", tags: ["t"], updated_at: 1, created_at: 1)
                let expectedNote = Note.Meta(uuid: "nUUID", title: "", tags: [], updated_at: 66, created_at: 66)

                beforeEach {
                    event = .addNote
                    e = e.evaluate(event: .didLoadNotes(notes: [anotherNote]))
                    e.currentTimestamp = { 66 }
                    e.generateUUID = { "nUUID" }
                    e = e.evaluate(event: event)
                }

                it("has addNote and showNote actions") {
                    expect(e.actions).to(equalDiff([
                        .addNote(note: Note.Model(meta: expectedNote, content: "", notebook: nil)),
                        .showNote(note: expectedNote, isNew: true)
                    ]))
                }

                it("updates model by adding new note meta") {
                    expect(e.model).to(equalDiff(
                        UI.Notebook.Model(notebook: notebook, notes: [expectedNote, anotherNote])
                    ))
                }

                // TODO: Add addNote effect
            }

            context("when receiving selectNote event") {
                let note = Note.Meta(uuid: "fU", title: "AB", tags: ["t"], updated_at: 1, created_at: 1)

                beforeEach {
                    event = .selectNote(index: 0)
                    e = e.evaluate(event: .didLoadNotes(notes: [note]))
                        .evaluate(event: event)
                }

                it("has showNote action") {
                    expect(e.actions).to(equalDiff([
                        .showNote(note: note, isNew: false)
                    ]))
                }
            }

            context("when receiving deleteNote event") {
                let note = Note.Meta(uuid: "fU", title: "AB", tags: ["t"], updated_at: 1, created_at: 1)

                beforeEach {
                    event = .deleteNote(index: 0)
                    e = e.evaluate(event: .didLoadNotes(notes: [note]))
                        .evaluate(event: event)
                }

                it("has deleteNote action") {
                    expect(e.actions).to(equalDiff([
                        .deleteNote(note: note)
                    ]))
                }
            }

            context("when receiving deleteNotebook event") {
                beforeEach {
                    event = .deleteNotebook
                    e = e.evaluate(event: event)
                }

                it("has deleteNotebook action") {
                    expect(e.actions).to(equalDiff([
                        .deleteNotebook(notebook: notebook)
                    ]))
                }
            }

            context("when receiving filterNotes event") {
                let firstNote = Note.Meta(uuid: "fU", title: "AB", tags: ["t"], updated_at: 1, created_at: 1)
                let secondNote = Note.Meta(uuid: "sU", title: "ab", tags: ["t"], updated_at: 2, created_at: 2)
                let thirdNote = Note.Meta(uuid: "tU", title: "g", tags: ["t"], updated_at: 3, created_at: 3)

                beforeEach {
                    e = e.evaluate(event: .didLoadNotes(notes: [firstNote, secondNote, thirdNote]))
                }

                context("when filter is not passed") {
                    beforeEach {
                        event = .filterNotes(filter: nil)
                        e = e.evaluate(event: event)
                    }

                    it("has updateAllNotes effect with all note's titles") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotes(notes: ["AB", "ab", "g"])
                        ]))
                    }
                }

                context("when filter is passed") {
                    beforeEach {
                        event = .filterNotes(filter: "aB")
                        e = e.evaluate(event: event)
                    }

                    it("has updateAllNotes effect with only titles that contains filter in any register") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotes(notes: ["AB", "ab"])
                        ]))
                    }
                }
            }

            context("when receiving didStartToEditTitle event") {
                beforeEach {
                    event = .didStartToEditTitle
                    e = e.evaluate(event: event)
                }

                it("has hideBackButton effect") {
                    expect(e.effects).to(equalDiff([
                        .hideBackButton
                    ]))
                }
            }

            context("when receiving didFinishToEditTitle event") {
                context("when title is passed") {
                    beforeEach {
                        event = .didFinishToEditTitle(newTitle: "new title")
                        e = e.evaluate(event: event)
                    }

                    it("has updateNotebook action with passed title") {
                        expect(e.actions).to(equalDiff([
                            .updateNotebook(notebook: notebook, title: "new title")
                        ]))
                    }

                    it("has showBackButton effect") {
                        expect(e.effects).to(equalDiff([
                            .showBackButton
                        ]))
                    }
                }

                context("when title is not passed") {
                    beforeEach {
                        event = .didFinishToEditTitle(newTitle: nil)
                        e = e.evaluate(event: event)
                    }

                    it("has updateNotebook action with empty title") {
                        expect(e.actions).to(equalDiff([
                            .updateNotebook(notebook: notebook, title: "")
                        ]))
                    }

                    it("has showBackButton effect") {
                        expect(e.effects).to(equalDiff([
                            .showBackButton
                        ]))
                    }
                }
            }
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

