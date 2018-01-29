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
        let model = Notebook.Model(notebook: notebook, notes: [], filter: Dummy.filter)
        var e: Notebook.Evaluator!

        beforeEach {
            e = Notebook.Evaluator(notebook: notebook)
        }

        describe("-evaluating:ViewEvent") {
            var event: Notebook.ViewEvent!

            context("when receiving didLoad event") {
                beforeEach {
                    event = .didLoad
                    e = e.evaluating(event: event)
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
                    e = e.evaluating(event: .didLoadNotes([anotherNote]))
                    e.currentTimestamp = { 66 }
                    e.generateUUID = { "nUUID" }
                    e = e.evaluating(event: event)
                }

                it("has addNote actions") {
                    expect(e.actions).to(equalDiff([
                        .addNote(expectedNote)
                    ]))
                }

                it("updates model by adding new note") {
                    expect(e.model).to(equalDiff(
                        Dummy.model(fromModel: model, notes:  [expectedNote, anotherNote])
                    ))
                }

                it("has addNote effect") {
                    expect(e.effects).to(equalDiff([
                        .addNote(index: 0, notes: ["", "aT"])
                    ]))
                }
            }

            context("when receiving selectNote event") {
                let note = Dummy.note(withTitle: "ab")
                let secondNote = Dummy.note(withTitle: "ac")
                let thirdNote = Dummy.note(withTitle: "b")

                beforeEach {
                    event = .selectNote(index: 1)
                    e = e.evaluating(event: .didLoadNotes([note, secondNote, thirdNote]))
                }

                context("when model has filter") {
                    beforeEach {
                        e = e.evaluating(event: .filterNotes(filter: "b"))
                            .evaluating(event: event)
                    }

                    it("has showNote action") {
                        expect(e.actions).to(equalDiff([
                            .showNote(thirdNote, isNew: false)
                        ]))
                    }
                }

                context("when model doesnt have filter") {
                    beforeEach {
                        e = e.evaluating(event: event)
                    }

                    it("has showNote action") {
                        expect(e.actions).to(equalDiff([
                            .showNote(secondNote, isNew: false)
                        ]))
                    }
                }
            }

            context("when receiving deleteNote event") {
                let note = Dummy.note(withTitle: "AB", tags: ["t"])

                beforeEach {
                    event = .deleteNote(index: 0)
                    e = e.evaluating(event: .didLoadNotes([note]))
                        .evaluating(event: event)
                }

                it("has deleteNote action") {
                    expect(e.actions).to(equalDiff([
                        .deleteNote(note)
                    ]))
                }

                it("has deleteNote effect") {
                    expect(e.effects).to(equalDiff([
                        .deleteNote(index: 0, notes: [])
                    ]))
                }

                it("updates model by removing note") {
                    expect(e.model).to(equalDiff(
                        Dummy.model(fromModel: model, notes:  [])
                    ))
                }
            }

            context("when receiving deleteNotebook event") {
                beforeEach {
                    event = .deleteNotebook
                    e = e.evaluating(event: event)
                }

                it("has deleteNotebook action") {
                    expect(e.actions).to(equalDiff([
                        .deleteNotebook
                    ]))
                }
            }

            context("when receiving filterNotes event") {
                let firstNote = Dummy.note(withTitle: "AB", tags: ["t"])
                let secondNote = Dummy.note(withTitle: "ab", tags: ["t"])
                let thirdNote = Dummy.note(withTitle: "g", tags: ["t"])

                beforeEach {
                    e = e.evaluating(event: .didLoadNotes([firstNote, secondNote, thirdNote]))
                }

                context("when filter is not passed") {
                    beforeEach {
                        event = .filterNotes(filter: nil)
                        e = e.evaluating(event: event)
                    }

                    it("updates model with empty filter") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notes:  [firstNote, secondNote, thirdNote], filter: "")
                        ))
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
                        e = e.evaluating(event: event)
                    }

                    it("updates model with lowecased filter") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notes:  [firstNote, secondNote, thirdNote], filter: "ab")
                        ))
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
                    e = e.evaluating(event: event)
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
                        e = e.evaluating(event: event)
                    }

                    it("has updateNotebook action with passed title") {
                        expect(e.actions).to(equalDiff([
                            .updateNotebook(title: "new title")
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
                        e = e.evaluating(event: event)
                    }

                    it("has updateNotebook action with empty title") {
                        expect(e.actions).to(equalDiff([
                            .updateNotebook(title: "")
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

        describe("-evaluating:CoordinatorEvent") {
            var event: Notebook.CoordinatorEvent!

            context("when receiving updateNote event") {
                let updatedNote = Dummy.note(withTitle: "new title")
                let anotherNote = Dummy.note(withTitle: "z")

                beforeEach {
                    event = .updateNote(updatedNote)
                }

                context("when note with that uuid is exist in model") {
                    beforeEach {
                        let oldNote = Dummy.note(withTitle: "old title", uuid: updatedNote.uuid)
                        e = e.evaluating(event: .didLoadNotes([anotherNote, oldNote]))
                            .evaluating(event: event)
                    }

                    it("updates model by replacing old note with new note") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notes: [updatedNote, anotherNote])
                        ))
                    }

                    it("has updateAllNotes effect") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotes(["new title", "z"])
                        ]))
                    }
                }

                context("when note with that uuid doesnt exist in model") {
                    beforeEach {
                        e = e.evaluating(event: .didLoadNotes([anotherNote]))
                            .evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notes: [anotherNote])
                        ))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }
            }

            context("when receiving deleteNote event") {
                let note = Dummy.note(withTitle: "deleted note title")
                let noteInModel = Dummy.note(withTitle: "old title", uuid: note.uuid)
                let anotherNote = Dummy.note(withTitle: "z")

                beforeEach {
                    event = .deleteNote(note)
                }

                context("when note with that uuid is exist in model") {
                    beforeEach {
                        e = e.evaluating(event: .didLoadNotes([anotherNote, noteInModel]))
                            .evaluating(event: event)
                    }

                    it("removes note with that uuid from model") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notes: [anotherNote])
                        ))
                    }

                    it("has deleteNote action") {
                        expect(e.actions).to(equalDiff([
                            .deleteNote(noteInModel)
                        ]))
                    }

                    it("has deleteNote effect") {
                        expect(e.effects).to(equalDiff([
                            .deleteNote(index: 0, notes: ["z"])
                        ]))
                    }
                }

                context("when note with that uuid doesnt exist in model") {
                    beforeEach {
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }
            }

            context("when receiving didLoadNotes") {
                context("when note list is empty") {
                    beforeEach {
                        event = .didLoadNotes([])
                        e = e.evaluating(event: event)
                    }

                    it("has model with empty notebooks") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notes: [])
                        ))
                    }

                    it("has updateAllNotes effect with empty viewModels") {
                        expect(e.effects).to(equalDiff([
                            .updateAllNotes([])
                        ]))
                    }
                }

                context("when notebook list is not empty") {
                    let firstNote = Dummy.note(withTitle: "ba", tags: ["t"])
                    let secondNote = Dummy.note(withTitle: "a", tags: ["t"])
                    let thirdNote = Dummy.note(withTitle: "C", tags: ["t"])

                    beforeEach {
                        event = .didLoadNotes([firstNote, secondNote, thirdNote])
                    }

                    context("when model has filter") {
                        beforeEach {
                            e = e.evaluating(event: .filterNotes(filter: "a"))
                                .evaluating(event: event)
                        }

                        it("has model with sorted by title notes") {
                            expect(e.model).to(equalDiff(
                                Dummy.model(fromModel: model, notes: [secondNote, firstNote, thirdNote], filter: "a")
                            ))
                        }

                        it("has updateAllNotes effect with sorted and filtered viewModels") {
                            expect(e.effects).to(equalDiff([
                                .updateAllNotes(["a", "ba"])
                            ]))
                        }
                    }

                    context("when model doesnt have filter") {
                        beforeEach {
                            e = e.evaluating(event: event)
                        }

                        it("has model with sorted by title notes") {
                            expect(e.model).to(equalDiff(
                                Dummy.model(fromModel: model, notes: [secondNote, firstNote, thirdNote])
                            ))
                        }

                        it("has updateAllNotes effect with sorted viewModels") {
                            expect(e.effects).to(equalDiff([
                                .updateAllNotes(["a", "ba", "C"])
                            ]))
                        }
                    }
                }
            }

            context("when receiving didUpdateNotebook event") {
                let oldNotebook = Core.Notebook.Meta(uuid: notebook.uuid, name: "old name")

                context("when successfuly updates notebook") {
                    let notebook = Dummy.notebook()

                    beforeEach {
                        event = .didUpdateNotebook(oldNotebook: oldNotebook, notebook: notebook, error: nil)
                        e = e.evaluating(event: event)
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("has didUpdateNotebook action") {
                        expect(e.actions).to(equalDiff([
                            .didUpdateNotebook(notebook)
                        ]))
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to update notebook") {
                    beforeEach {
                        let notebook = Dummy.notebook()
                        event = .didUpdateNotebook(oldNotebook: oldNotebook, notebook: notebook, error: Dummy.error)
                        e = e.evaluating(event: event)
                    }

                    it("has updateTitle effect") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle("old name")
                        ]))
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.updateNotebook, reason: Dummy.errorMessage)
                        ]))
                    }

                    it("updates model by setting notebook to the old") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notebook: oldNotebook)
                        ))
                    }
                }
            }

            context("when receiving didDeleteNotebook event") {
                context("when successfuly deletes notebook") {
                    beforeEach {
                        event = .didDeleteNotebook(error: nil)
                        e = e.evaluating(event: event)
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
                        e = e.evaluating(event: event)
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.deleteNotebook, reason: Dummy.errorMessage)
                        ]))
                    }
                }
            }

            context("when receiving didAddNote event") {
                let note = Dummy.note(withTitle: "aT", tags: ["t"])
                let addedNote = Dummy.note(withTitle: "sN", tags: [])

                beforeEach {
                    e = e.evaluating(event: .didLoadNotes([note, addedNote]))
                }

                context("when successfully adds note") {
                    beforeEach {
                        event = .didAddNote(addedNote, error: nil)
                        e = e.evaluating(event: event)
                    }

                    it("has showNote action") {
                        expect(e.actions).to(equalDiff([
                            .showNote(addedNote, isNew: true)
                        ]))
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notes: [note, addedNote])
                        ))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }

                context("when fails to add note") {
                    beforeEach {
                        event = .didAddNote(addedNote, error: Dummy.error)
                        e = e.evaluating(event: event)
                    }

                    it("removes note from model") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notes: [note])
                        ))
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.addNote, reason: Dummy.errorMessage)
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
                    e = e.evaluating(event: .didLoadNotes([note]))
                }

                context("when successfully deletes note") {
                    beforeEach {
                        event = .didDeleteNote(deletedNote, error: nil)
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notes: [note])
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
                        e = e.evaluating(event: event)
                    }

                    it("adds deleted note back to model") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, notes: [deletedNote, note])
                        ))
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.deleteNote, reason: Dummy.errorMessage)
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
    static let filter = ""

    static func note(withTitle title: String, tags: [String] = [], uuid: String = UUID().uuidString, date: Double = 5) -> Core.Note.Meta {
        return Core.Note.Meta(uuid: uuid, title: title, tags: tags, updated_at: date, created_at: date)
    }

    static func model(fromModel model: Notebook.Model, notebook: Core.Notebook.Meta? = nil,
                      notes: [Core.Note.Meta]? = nil, filter: String? = nil) -> Notebook.Model {
        return Notebook.Model(notebook: notebook ?? model.notebook,
                              notes: notes ?? model.notes,
                              filter: filter ?? model.filter)
    }

    static func notebook(withUUUID uuid: String = UUID.init().uuidString,
                         title: String = "title") -> Core.Notebook.Meta {
        return Core.Notebook.Meta(uuid: uuid, name: title)
    }
}
