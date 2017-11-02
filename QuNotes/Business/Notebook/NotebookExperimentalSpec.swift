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
        let model = Experimental.Notebook.Model(uuid: "uuid", name: "name", notes: [])
        var e: Experimental.Notebook.Evaluator!

        beforeEach {
            e = Experimental.Notebook.Evaluator(model: model)
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
                let noteToAdd = Experimental.Note.Model(uuid: "noteUUID", title: "title", content: "content")
                let expectedNoteMeta = Experimental.Note.Meta(uuid: "noteUUID", title: "title")
                let expectedNoteContent = Experimental.Note.Content(content: "content")

                beforeEach {
                    event = .addNote(note: noteToAdd)
                }

                context("when note with that uuid is not added yet") {
                    it("has createFile action with URL of new note meta") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.createFile(url: URL(string: "uuid.qvnotebook/noteUUID.qvnote/meta.json")!,
                                                  content: expectedNoteMeta)))
                    }

                    it("has createFile action with URL of new note content") {
                        expect(e.evaluate(event: event).actions[1])
                            .to(equal(.createFile(url: URL(string: "uuid.qvnotebook/noteUUID.qvnote/content.json")!,
                                                  content: expectedNoteContent)))
                    }

                    it("updates model by adding new note") {
                        expect(e.evaluate(event: event).model.notes[0])
                            .to(equal(noteToAdd))
                    }
                }

                context("when note with that uuid is already added") {
                    let alreadyAddedNote = Experimental.Note.Model(uuid: "noteUUID",
                                                                   title: "another title",
                                                                   content: "another content")

                    beforeEach {
                        e = e.evaluate(event: .addNote(note: alreadyAddedNote))
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model.notes[0])
                            .to(equal(alreadyAddedNote))
                    }
                }
            }

            context("when receiving removeNote event") {
                let noteToRemove = Experimental.Note.Model(uuid: "noteUUID", title: "title", content: "content")

                beforeEach {
                    event = .removeNote(note: noteToRemove)
                }

                context("when passed note is exist") {
                    beforeEach {
                        e = e.evaluate(event: .addNote(note: noteToRemove))
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
                    it("has no actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }
                }
            }
        }
    }
}
