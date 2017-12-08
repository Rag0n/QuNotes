//
//  NotebookExperimentalSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NotebookSpec: QuickSpec {
    override func spec() {
        let error = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])
        let note = Note.Meta(uuid: "noteUUID", title: "title", tags: [], updated_at: 0, created_at: 123)
        let meta = Notebook.Meta(uuid: "uuid", name: "name")
        let model = Notebook.Model(meta: meta, notes: [note])
        var e: Notebook.Evaluator!

        beforeEach {
            e = Notebook.Evaluator(model: model)
        }

        context("when initialized") {
            it("has zero effects") {
                expect(e.effects).to(beEmpty())
            }

            it("has passed model") {
                expect(e.model).to(equalDiff(model))
            }
        }

        describe("-evaluate:") {
            var event: Notebook.Event!

            context("when receiving loadNotes event") {
                beforeEach {
                    event = .loadNotes
                    e = e.evaluate(event: event)
                }

                it("doesnt update model") {
                    expect(e.model).to(equalDiff(model))
                }

                it("has readDirectory effect") {
                    expect(e.effects).to(equalDiff([
                        .readDirectory(atURL: URL(string: "uuid.qvnotebook")!)
                    ]))
                }
            }

            context("when receiving changeName event") {
                beforeEach {
                    event = .changeName(newName: "new name")
                    e = e.evaluate(event: event)
                }

                it("has updateFile effect with notebook & notebook URL") {
                    expect(e.effects).to(equalDiff([
                        .updateNotebook(notebook: Notebook.Meta(uuid: "uuid", name: "new name"),
                                        url: URL(string: "uuid.qvnotebook/meta.json")!)
                    ]))
                }

                it("updates model by changing name") {
                    expect(e.model).to(equalDiff(
                        Notebook.Model(meta: Notebook.Meta(uuid: "uuid", name: "new name"), notes: [note])
                    ))
                }
            }

            context("when receiving addNote event") {
                context("when note with that uuid is not added yet") {
                    let newNote = Note.Meta(uuid: "newNoteUUID", title: "title", tags: ["tag"],
                                            updated_at: 12, created_at: 12)

                    beforeEach {
                        event = .addNote(note: newNote)
                        e = e.evaluate(event: event)
                    }

                    it("has createNote effect") {
                        expect(e.effects).to(equalDiff([
                            .createNote(note: Note.Meta(uuid: "newNoteUUID", title: "title", tags: ["tag"],
                                                        updated_at: 12, created_at: 12),
                                        url: URL(string: "uuid.qvnotebook/newNoteUUID.qvnote/meta.json")!)
                        ]))
                    }

                    it("updates model by adding new note") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(meta: meta, notes: [note, newNote])
                        ))
                    }
                }

                context("when note with that uuid is already added") {
                    beforeEach {
                        event = .addNote(note: note)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }
            }

            context("when receiving removeNote event") {
                context("when passed note is exist") {
                    beforeEach {
                        event = .removeNote(note: note)
                        e = e.evaluate(event: event)
                    }

                    it("has deleteFile effect with URL of deleted note") {
                        expect(e.effects).to(equalDiff([
                            .deleteNote(note: note, url: URL(string: "uuid.qvnotebook/noteUUID.qvnote")!)
                        ]))
                    }

                    it("updates model by removing passed note") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(meta: meta, notes: [])
                        ))
                    }
                }

                context("when passed note is not exist") {
                    beforeEach {
                        let notAddedNote = Note.Meta(uuid: "nAUUID", title: "t", tags: [],
                                                     updated_at: 14, created_at: 14)
                        event = .removeNote(note: notAddedNote)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }
            }

            context("when receiving didReadDirectory event") {
                context("when successfuly reads directories") {
                    beforeEach {
                        let urls = [
                            URL(string: "/uuid/firstNote.qvnote")!,
                            URL(string: "/uuid/notANote.txt")!,
                            URL(string: "/uuid/secondNote.qvnote")!,
                        ]
                        event = .didReadDirectory(urls: Result(value: urls))
                        e = e.evaluate(event: event)
                    }

                    it("has readNotes effect with notes urls") {
                        expect(e.effects).to(equalDiff([
                            .readNotes(urls: [URL(string: "/uuid/firstNote.qvnote/meta.json")!,
                                              URL(string: "/uuid/secondNote.qvnote/meta.json")!])
                        ]))
                    }
                }

                context("when fails to read directories") {
                    beforeEach {
                        event = .didReadDirectory(urls: Result(error: error))
                        e = e.evaluate(event: event)
                    }

                    it("has handleError effect") {
                        expect(e.effects).to(equalDiff([
                            .handleError(title: "Failed to load notes", message: "message")
                        ]))
                    }
                }
            }

            context("when receiving didReadNotes event") {
                context("when note list is empty") {
                    beforeEach {
                        event = .didReadNotes(notes: [])
                        e = e.evaluate(event: event)
                    }

                    it("has didLoadNotes effect with empty list") {
                        expect(e.effects).to(equalDiff([
                            .didLoadNotes(notes: [])
                        ]))
                    }
                }

                context("when note list has result with note") {
                    beforeEach {
                        let note = Note.Meta(uuid: "u", title: "t", tags: ["t"], updated_at: 2, created_at: 2)
                        event = .didReadNotes(notes: [Result(value: note)])
                        e = e.evaluate(event: event)
                    }

                    it("has didLoadNotes effect with 1 note") {
                        expect(e.effects).to(equalDiff([
                            .didLoadNotes(notes: [Note.Meta(uuid: "u", title: "t", tags: ["t"],
                                                            updated_at: 2, created_at: 2)])
                        ]))
                    }
                }

                context("when note list has result with error") {
                    beforeEach {
                        event = .didReadNotes(notes: [Result(error: AnyError(error))])
                        e = e.evaluate(event: event)
                    }

                    it("has handleError effect with message from error") {
                        expect(e.effects).to(equalDiff([
                            .handleError(title: "Unable to load notes", message: "message")
                        ]))
                    }
                }

                context("when note list has result with note and several errors") {
                    beforeEach {
                        let note = Note.Meta(uuid: "u", title: "t", tags: ["t"], updated_at: 2, created_at: 2)
                        let secondError = NSError(domain: "error domain", code: 1,
                                                  userInfo: [NSLocalizedDescriptionKey: "secondMessage"])
                        event = .didReadNotes(notes: [Result(error: AnyError(error)),
                                                      Result(value: note),
                                                      Result(error: AnyError(secondError))])
                        e = e.evaluate(event: event)
                    }

                    it("has handleError effect with combined message from errors") {
                        expect(e.effects).to(equalDiff([
                            .handleError(title: "Unable to load notes", message: "message\nsecondMessage")
                        ]))
                    }
                }
            }
        }
    }
}
