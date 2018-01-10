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
        let error = Dummy.error(withMessage: "message")
        let note = Dummy.note(uuid: "noteUUID")
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
                    event = .changeName("new name")
                    e = e.evaluate(event: event)
                }

                it("has updateFile effect with notebook & notebook URL") {
                    expect(e.effects).to(equalDiff([
                        .updateNotebook(Notebook.Meta(uuid: "uuid", name: "new name"),
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
                    let newNote = Dummy.note(uuid: "newNoteUUID")

                    beforeEach {
                        event = .addNote(newNote)
                        e = e.evaluate(event: event)
                    }

                    it("has createNote effects") {
                        expect(e.effects).to(equalDiff([
                            .createNote(newNote,
                                        url: URL(string: "uuid.qvnotebook/newNoteUUID.qvnote/meta.json")!,
                                        content: Note.Content(title: newNote.title, cells: []),
                                        contentURL: URL(string: "uuid.qvnotebook/newNoteUUID.qvnote/content.json")!)
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
                        event = .addNote(note)
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
                        event = .removeNote(note)
                        e = e.evaluate(event: event)
                    }

                    it("has deleteFile effect with URL of deleted note") {
                        expect(e.effects).to(equalDiff([
                            .deleteNote(note, url: URL(string: "uuid.qvnotebook/noteUUID.qvnote")!)
                        ]))
                    }

                    it("updates model by removing passed note") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(meta: meta, notes: [])
                        ))
                    }
                }

                context("when passed note is not exist") {
                    let notAddedNote = Dummy.note()

                    beforeEach {
                        event = .removeNote(notAddedNote)
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
                        event = .didReadNotes([])
                        e = e.evaluate(event: event)
                    }

                    it("has didLoadNotes effect with empty list") {
                        expect(e.effects).to(equalDiff([
                            .didLoadNotes([])
                        ]))
                    }
                }

                context("when note list has result with note") {
                    let note = Dummy.note()

                    beforeEach {
                        event = .didReadNotes([Result(value: note)])
                        e = e.evaluate(event: event)
                    }

                    it("has didLoadNotes effect with 1 note") {
                        expect(e.effects).to(equalDiff([
                            .didLoadNotes([note])
                        ]))
                    }
                }

                context("when note list has result with error") {
                    beforeEach {
                        event = .didReadNotes([Result(error: AnyError(error))])
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
                        let note = Dummy.note()
                        let secondError = Dummy.error(withMessage: "secondMessage")
                        event = .didReadNotes([Result(error: AnyError(error)),
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

            context("when receiving didAddNote event") {
                context("when successfully adds note") {
                    beforeEach {
                        let note = Dummy.note()
                        event = .didAddNote(note, error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to add note") {
                    beforeEach {
                        event = .didAddNote(note, error: error)
                        e = e.evaluate(event: event)
                    }

                    it("removes note from model") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(meta: model.meta, notes: [])
                        ))
                    }

                    it("has removeFile effect with note's meta and content") {
                        expect(e.effects).to(equalDiff([
                            .removeFile(url:  URL(string: "uuid.qvnotebook/noteUUID.qvnote/meta.json")!),
                            .removeFile(url:  URL(string: "uuid.qvnotebook/noteUUID.qvnote/content.json")!),
                        ]))
                    }
                }
            }

            context("when receiving didDeleteNote event") {
                context("when successfully deletes note") {
                    beforeEach {
                        event = .didDeleteNote(note, error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to delete note") {
                    let deletedNote = Dummy.note()

                    beforeEach {
                        event = .didDeleteNote(deletedNote, error: error)
                        e = e.evaluate(event: event)
                    }

                    it("adds note back to model") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(meta: model.meta, notes: [note, deletedNote])
                        ))
                    }
                }
            }

            context("when receiving didUpdateNotebook event") {
                let oldNotebook = Notebook.Meta(uuid: meta.uuid, name: "old name")

                context("when successfilly updated notebook") {
                    beforeEach {
                        event = .didUpdateNotebook(oldNotebook, error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to update notebook") {
                    beforeEach {
                        event = .didUpdateNotebook(oldNotebook, error: error)
                        e = e.evaluate(event: event)
                    }

                    it("updates model by setting the old name") {
                        expect(e.model).to(equalDiff(
                            Notebook.Model(meta: oldNotebook, notes: model.notes)
                        ))
                    }
                }
            }
        }
    }
}

private enum Dummy {
    static func note(uuid: String = UUID().uuidString) -> Note.Meta {
        return Note.Meta(uuid: uuid, title: uuid + "title", tags: [uuid + "tag"], updated_at: 7, created_at: 7)
    }

    static func error(withMessage message: String) -> NSError {
        return NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
