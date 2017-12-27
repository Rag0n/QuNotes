//
//  NotebookEvaluatorSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 19.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Core

class NotebookEvaluatorSpec: QuickSpec {
    override func spec() {
        let notebook = Core.Notebook.Meta(uuid: "uuid", name: "name")
        var e: Notebook.Evaluator!

        beforeEach {
            e = Notebook.Evaluator(notebook: notebook)
        }

        describe("-evaluate:ViewEvent") {
            var event: Notebook.ViewEvent!

            context("when receiving didLoad event") {
                beforeEach {
                    event = .didLoad
                    e = e.evaluate(event: event)
                }

                it("has updateTitle effect") {
                    expect(e.effects).to(equalDiff([
                        .updateTitle("name")
                    ]))
                }
            }

            context("when receiving addNote event") {

                let anotherNote = Dummy.note(withTitle: "aT", tags: ["t"])
                let expectedNote = Dummy.note(withTitle: "", uuid: "nUUID", date: 66)

                beforeEach {
                    event = .addNote
                    e = e.evaluate(event: .didLoadNotes([anotherNote]))
                    e.currentTimestamp = { 66 }
                    e.generateUUID = { "nUUID" }
                    e = e.evaluate(event: event)
                }

                it("has addNote actions") {
                    expect(e.actions).to(equalDiff([
                        .addNote(expectedNote)
                    ]))
                }

                it("updates model by adding new note") {
                    expect(e.model).to(equalDiff(
                        Notebook.Model(notebook: notebook, notes: [expectedNote, anotherNote])
                    ))
                }

                it("has addNote effect") {
                    expect(e.effects).to(equalDiff([
                        .addNote(index: 0, notes: ["", "aT"])
                    ]))
                }
            }

            context("when receiving selectNote event") {
                let note = Dummy.note(withTitle: "AB", tags: ["t"])

                beforeEach {
                    event = .selectNote(index: 0)
                    e = e.evaluate(event: .didLoadNotes([note]))
                        .evaluate(event: event)
                }

                it("has showNote action") {
                    expect(e.actions).to(equalDiff([
                        .showNote(note, isNew: false)
                    ]))
                }
            }

            context("when receiving deleteNote event") {
                let note = Dummy.note(withTitle: "AB", tags: ["t"])

                beforeEach {
                    event = .deleteNote(index: 0)
                    e = e.evaluate(event: .didLoadNotes([note]))
                        .evaluate(event: event)
                }

                it("has deleteNote action") {
                    expect(e.actions).to(equalDiff([
                        .deleteNote(note)
                    ]))
                }

                it("updates model by removing note") {
                    expect(e.model).to(equalDiff(
                        Notebook.Model(notebook: notebook, notes: [])
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
                        .deleteNotebook(notebook)
                    ]))
                }
            }

            context("when receiving filterNotes event") {
                let firstNote = Dummy.note(withTitle: "AB", tags: ["t"])
                let secondNote = Dummy.note(withTitle: "ab", tags: ["t"])
                let thirdNote = Dummy.note(withTitle: "g", tags: ["t"])

                beforeEach {
                    e = e.evaluate(event: .didLoadNotes([firstNote, secondNote, thirdNote]))
                }

                context("when filter is not passed") {
                    beforeEach {
                        event = .filterNotes(filter: nil)
                        e = e.evaluate(event: event)
                    }

                    it("has updateAllNotes effect with all note's titles") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotes(["AB", "ab", "g"])
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
                            .updateAllNotes(["AB", "ab"])
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
                            .updateNotebook(notebook, title: "new title")
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
                            .updateNotebook(notebook, title: "")
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
            var event: Notebook.CoordinatorEvent!

            context("when receiving didLoadNotes") {
                context("when note list is empty") {
                    beforeEach {
                        event = .didLoadNotes([])
                        e = e.evaluate(event: event)
                    }

                    it("has model with empty notebooks") {
                        expect(e.model).to(equalDiff(Notebook.Model(notebook: notebook, notes: [])))
                    }

                    it("has updateAllNotebooks effect with empty viewModels") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotes([])
                        ]))
                    }
                }

                context("when notebook list is not empty") {
                    let firstNote = Dummy.note(withTitle: "b", tags: ["t"])
                    let secondNote = Dummy.note(withTitle: "a", tags: ["t"])
                    let thirdNote = Dummy.note(withTitle: "C", tags: ["t"])

                    beforeEach {
                        event = .didLoadNotes([firstNote, secondNote, thirdNote])
                        e = e.evaluate(event: event)
                    }

                    it("has model with sorted by name notebooks") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(notebook: notebook, notes: [secondNote, firstNote, thirdNote])
                        ))
                    }

                    it("has updateAllNotebooks effect with sorted viewModels") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotes(["a", "b", "C"])
                        ]))
                    }
                }
            }

            context("when receiving didUpdateNotebook event") {
                let oldNotebook = Core.Notebook.Meta(uuid: notebook.uuid, name: "old name")

                context("when successfuly updates notebook") {
                    beforeEach {
                        event = .didUpdateNotebook(oldNotebook, error: nil)
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
                            Notebook.Model(notebook: notebook, notes: [])
                        ))
                    }
                }

                context("when fails to update notebook") {
                    beforeEach {
                        event = .didUpdateNotebook(oldNotebook, error: Dummy.error)
                        e = e.evaluate(event: event)
                    }

                    it("has updateTitle effect") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle("old name")
                        ]))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to update notebook's title",
                                       message: Dummy.errorMessage)
                        ]))
                    }

                    it("updates model by setting notebook to the old") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(notebook: oldNotebook, notes: [])
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
                        event = .didDeleteNotebook(error: Dummy.error)
                        e = e.evaluate(event: event)
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to delete notebook",
                                       message: Dummy.errorMessage)
                        ]))
                    }
                }
            }

            context("when receiving didAddNote event") {

                let note = Dummy.note(withTitle: "aT", tags: ["t"])
                let addedNote = Dummy.note(withTitle: "sN", tags: [])

                beforeEach {
                    e = e.evaluate(event: .didLoadNotes([note, addedNote]))
                }

                context("when successfully adds note") {
                    beforeEach {
                        event = .didAddNote(addedNote, error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("has showNote action") {
                        expect(e.actions).to(equalDiff([
                            .showNote(addedNote, isNew: true)
                        ]))
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(notebook: notebook, notes: [note, addedNote])
                        ))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }

                context("when fails to add note") {
                    beforeEach {
                        event = .didAddNote(addedNote, error: Dummy.error)
                        e = e.evaluate(event: event)
                    }

                    it("removes note from model") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(notebook: notebook, notes: [note])
                        ))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to add note", message: Dummy.errorMessage)
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

                let note = Dummy.note(withTitle: "bT", tags: ["t"])
                let deletedNote = Dummy.note(withTitle: "aN")

                beforeEach {
                    e = e.evaluate(event: .didLoadNotes([note]))
                }

                context("when successfully deletes note") {
                    beforeEach {
                        event = .didDeleteNote(deletedNote, error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(notebook: notebook, notes: [note])
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
                        event = .didDeleteNote(deletedNote, error: Dummy.error)
                        e = e.evaluate(event: event)
                    }

                    it("adds deleted note back to model") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(notebook: notebook, notes: [deletedNote, note])
                        ))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to delete note", message: Dummy.errorMessage)
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

private enum Dummy {
    static let error = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
    static let errorMessage = "message"

    static func note(withTitle title: String, tags: [String] = [], uuid: String = UUID().uuidString, date: Double = 5) -> Core.Note.Meta {
        return Core.Note.Meta(uuid: uuid, title: title, tags: tags, updated_at: date, created_at: date)
    }
}
