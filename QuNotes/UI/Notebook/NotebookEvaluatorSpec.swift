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

                it("has addNote actions") {
                    expect(e.actions).to(equalDiff([
                        .addNote(note: expectedNote)
                    ]))
                }

                it("updates model by adding new note") {
                    expect(e.model).to(equalDiff(
                        UI.Notebook.Model(notebook: notebook, notes: [expectedNote, anotherNote])
                    ))
                }

                it("has addNote effect") {
                    expect(e.effects).to(equalDiff([
                        .addNote(index: 0, notes: ["", "aT"])
                    ]))
                }
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

                it("updates model by removing note") {
                    expect(e.model).to(equalDiff(
                        UI.Notebook.Model(notebook: notebook, notes: [])
                    ))
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

            context("when receiving didUpdateNotebook event") {
                let oldNotebook = Notebook.Meta(uuid: notebook.uuid, name: "old name")

                context("when successfuly updates notebook") {
                    beforeEach {
                        event = .didUpdateNotebook(notebook: oldNotebook, error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(
                            UI.Notebook.Model(notebook: notebook, notes: [])
                        ))
                    }
                }

                context("when fails to update notebook") {
                    beforeEach {
                        event = .didUpdateNotebook(notebook: oldNotebook, error: error)
                        e = e.evaluate(event: event)
                    }

                    it("has updateTitle effect") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle(title: "old name")
                        ]))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to update notebook's title",
                                       message: error.localizedDescription)
                        ]))
                    }

                    it("updates model by setting notebook to the old") {
                        expect(e.model).to(equalDiff(
                            UI.Notebook.Model(notebook: oldNotebook, notes: [])
                        ))
                    }
                }
            }

            context("when receiving didDeleteNotebook event") {
                context("when successfuly deletes notebook") {
                    beforeEach {
                        event = .didDeleteNotebook(error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("has finish action") {
                        expect(e.actions).to(equalDiff([
                            .finish
                        ]))
                    }
                }

                context("when fails to delete notebook") {
                    beforeEach {
                        event = .didDeleteNotebook(error: error)
                        e = e.evaluate(event: event)
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to delete notebook",
                                       message: error.localizedDescription)
                        ]))
                    }
                }
            }

            context("when receiving didAddNote event") {

                let note = Note.Meta(uuid: "aU", title: "aT", tags: ["t"], updated_at: 1, created_at: 1)
                let addedNote = Note.Meta(uuid: "fU", title: "sN", tags: [], updated_at: 6, created_at: 6)

                beforeEach {
                    e = e.evaluate(event: .didLoadNotes(notes: [note, addedNote]))
                }

                context("when successfully adds note") {
                    beforeEach {
                        event = .didAddNote(note: addedNote, error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("has showNote action") {
                        expect(e.actions).to(equalDiff([
                            .showNote(note: addedNote, isNew: true)
                        ]))
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(
                            UI.Notebook.Model(notebook: notebook, notes: [note, addedNote])
                        ))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }

                context("when fails to add note") {
                    beforeEach {
                        event = .didAddNote(note: addedNote, error: error)
                        e = e.evaluate(event: event)
                    }

                    it("removes note from model") {
                        expect(e.model).to(equalDiff(
                            UI.Notebook.Model(notebook: notebook, notes: [note])
                        ))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to add note", message: error.localizedDescription)
                        ]))
                    }

                    it(("has deleteNote effect")) {
                        expect(e.effects).to(equalDiff([
                            .deleteNote(index: 1, notes: ["aT"])
                        ]))
                    }
                }
            }

            context("when receiving didDeleteNote event") {

                let note = Note.Meta(uuid: "bU", title: "bT", tags: ["t"], updated_at: 1, created_at: 1)
                let deletedNote = Note.Meta(uuid: "aU", title: "aN", tags: [], updated_at: 6, created_at: 6)

                beforeEach {
                    e = e.evaluate(event: .didLoadNotes(notes: [note]))
                }

                context("when successfully deletes note") {
                    beforeEach {
                        event = .didDeleteNote(note: deletedNote, error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(
                            UI.Notebook.Model(notebook: notebook, notes: [note])
                        ))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }

                context("when fails to delete note") {
                    beforeEach {
                        event = .didDeleteNote(note: deletedNote, error: error)
                        e = e.evaluate(event: event)
                    }

                    it("adds deleted note back to model") {
                        expect(e.model).to(equalDiff(
                            UI.Notebook.Model(notebook: notebook, notes: [deletedNote, note])
                        ))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to delete note", message: error.localizedDescription)
                        ]))
                    }

                    it("has addNote effect") {
                        expect(e.effects).to(equalDiff([
                            .addNote(index: 0, notes: ["aN", "bT"])
                        ]))
                    }
                }
            }
        }
    }
}
