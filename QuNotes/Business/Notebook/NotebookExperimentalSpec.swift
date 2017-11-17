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
        let note = Experimental.Note.Model(uuid: "noteUUID", title: "title", content: "content", tags: [], notebook: nil, updatedDate: 0, createdDate: 123)
        let model = Experimental.Notebook.Model(uuid: "uuid", name: "name", notes: [note])
        let e = Experimental.Notebook.Evaluator(model: model)

        context("when initialized") {
            it("has zero actions") {
                expect(e.actions).to(beEmpty())
            }

            it("has passed model") {
                expect(e.model).to(equal(model))
            }
        }

        describe("-evaluate:") {
            var event: Experimental.Notebook.InputEvent!

            context("when receiving changeName event") {
                let expectedMetaContent = Experimental.Notebook.Meta(uuid: "uuid", name: "new name")

                beforeEach {
                    event = .changeName(newName: "new name")
                }

                it("has updateFile action with notebook's URL") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.updateFile(url: URL(string: "uuid.qvnotebook/meta.json")!,
                                              content: expectedMetaContent)))
                }

                it("updates model by changing notebook name") {
                    expect(e.evaluate(event: event).model.name)
                        .to(equal("new name"))
                }
            }

            context("when receiving addNote event") {
                context("when note with that uuid is not added yet") {
                    let newNote = Experimental.Note.Model(uuid: "newNoteUUID", title: "title", content: "content", tags: ["tag"], notebook: nil, updatedDate: 0, createdDate: 12)
                    let expectedNoteMeta = Experimental.Note.Meta(uuid: "newNoteUUID", title: "title",
                                                                  tags: ["tag"],
                                                                  updated_at: Date().timeIntervalSince1970,
                                                                  created_at: 12)
                    let expectedNoteContent = Experimental.Note.Content(content: "content")

                    beforeEach {
                        event = .addNote(note: newNote)
                    }

                    it("has createFile action with URL of new note meta") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.createFile(url: URL(string: "uuid.qvnotebook/newNoteUUID.qvnote/meta.json")!,
                                                  content: expectedNoteMeta)))
                    }

                    it("has createFile action with URL of new note content") {
                        expect(e.evaluate(event: event).actions[1])
                            .to(equal(.createFile(url: URL(string: "uuid.qvnotebook/newNoteUUID.qvnote/content.json")!,
                                                  content: expectedNoteContent)))
                    }

                    it("updates model by adding new note") {
                        expect(e.evaluate(event: event).model.notes)
                            .to(contain(newNote))
                    }
                }

                context("when note with that uuid is already added") {
                    beforeEach {
                        event = .addNote(note: note)
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model)
                            .to(equal(model))
                    }
                }
            }

            context("when receiving removeNote event") {
                context("when passed note is exist") {
                    beforeEach {
                        event = .removeNote(note: note)
                    }

                    it("has deleteFile action with URL of deleted note") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.deleteFile(url: URL(string: "uuid.qvnotebook/noteUUID.qvnote")!)))
                    }

                    it("updates model by removing passed note") {
                        expect(e.evaluate(event: event).model.notes)
                            .to(beEmpty())
                    }
                }

                context("when passed note is not exist") {
                    let notAddedNote = Experimental.Note.Model(uuid: "noteAddedNoteUUID", title: "title", content: "content", tags: [], notebook: nil, updatedDate: 0, createdDate: 14)

                    beforeEach {
                        event = .removeNote(note: notAddedNote)
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model)
                            .to(equal(model))
                    }
                }
            }
        }
    }
}
