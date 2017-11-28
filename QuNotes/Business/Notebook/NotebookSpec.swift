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

class NotebookExperimantalSpec: QuickSpec {
    override func spec() {
        let error = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])
        let note = Note.Model(uuid: "noteUUID", title: "title", content: "content", tags: [], notebook: nil,
                              updatedDate: 0, createdDate: 123)
        let meta = Notebook.Meta(uuid: "uuid", name: "name")
        let model = Notebook.Model(meta: meta, notes: [note])
        var e: Notebook.Evaluator!

        beforeEach {
            e = Notebook.Evaluator(model: model)
        }

        context("when initialized") {
            it("has zero actions") {
                expect(e.actions).to(beEmpty())
            }

            it("has passed model") {
                expect(e.model).to(equalDiff(model))
            }
        }

        describe("-evaluate:") {
            var event: Notebook.InputEvent!

            context("when receiving loadNotes event") {
                beforeEach {
                    event = .loadNotes
                    e = e.evaluate(event: event)
                }

                it("doesnt update model") {
                    expect(e.model).to(equalDiff(model))
                }

                it("has readDirectory action") {
                    expect(e.actions).to(equalDiff([
                        Notebook.Action.readDirectory(atURL: URL(string: "uuid.qvnotebook")!)
                    ]))
                }
            }

            context("when receiving changeName event") {
                beforeEach {
                    event = .changeName(newName: "new name")
                    e = e.evaluate(event: event)
                }

                it("has updateFile action with notebook & notebook URL") {
                    expect(e.actions).to(equalDiff([
                        .updateFile(url: URL(string: "uuid.qvnotebook/meta.json")!,
                                    content: Notebook.Meta(uuid: "uuid", name: "new name"))
                    ]))
                }

                it("updates model by changing name") {
                    expect(e.model).to(equalDiff(
                        Notebook.Model(uuid: "uuid", name: "new name", notes: [note])
                    ))
                }
            }

            context("when receiving addNote event") {
                context("when note with that uuid is not added yet") {
                    let newNote = Note.Model(uuid: "newNoteUUID", title: "title", content: "content", tags: ["tag"],
                                             notebook: nil, updatedDate: 12, createdDate: 12)

                    beforeEach {
                        event = .addNote(note: newNote)
                        e = e.evaluate(event: event)
                    }

                    it("has createFile actions with URL of new meta and content") {
                        expect(e.actions).to(equalDiff([
                            .createFile(url: URL(string: "uuid.qvnotebook/newNoteUUID.qvnote/meta.json")!,
                                        content: Note.Meta(uuid: "newNoteUUID", title: "title", tags: ["tag"],
                                                           updated_at: 12, created_at: 12)),
                            .createFile(url: URL(string: "uuid.qvnotebook/newNoteUUID.qvnote/content.json")!,
                                        content: Note.Content(content: "content"))
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

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
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

                    it("has deleteFile action with URL of deleted note") {
                        expect(e.actions).to(equalDiff([
                            .deleteFile(url: URL(string: "uuid.qvnotebook/noteUUID.qvnote")!)
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
                        let notAddedNote = Note.Model(uuid: "nAUUID", title: "t", content: "c", tags: [],
                                                      notebook: nil, updatedDate: 14, createdDate: 14)
                        event = .removeNote(note: notAddedNote)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }
            }

            fcontext("when receiving didReadDirectory event") {
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

                    it("has readNotes action with notes urls") {
                        expect(e.actions).to(equalDiff([
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

                    it("has handleError action") {
                        expect(e.actions).to(equalDiff([
                            .handleError(title: "Failed to load notes", message: "message")
                        ]))
                    }
                }
            }
        }
    }
}
