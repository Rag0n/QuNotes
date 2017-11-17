//
//  NoteExperimentalSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NoteExperimantalSpec: QuickSpec {
    override func spec() {
        let model = Experimental.Note.Model(uuid: "uuid", title: "title", content: "content",
                                            tags: [], updatedDate: 0, createdDate: 12)
        var e: Experimental.Note.Evaluator!

        beforeEach {
            e = Experimental.Note.Evaluator(model: model)
        }

        context("when initialized") {
            it("has zero actions") {
                expect(e.actions).to(beEmpty())
            }

            it("has passed model") {
                expect(e.model).to(equal(model))
            }
        }

        describe("-evaluate:") {
            var event: Experimental.Note.InputEvent!

            context("when receiving changeTitle event") {
                beforeEach {
                    event = .changeTitle(newTitle: "new title")
                    e.currentTimestamp = { 15 }
                }

                it("updates model by changing note title") {
                    expect(e.evaluate(event: event).model.title)
                        .to(equal("new title"))
                }

                it("updates model's updateDate") {
                    expect(e.evaluate(event: event).model.updatedDate)
                        .to(equal(15))
                }

                context("when note is added to notebook") {
                    let notebookModel = Experimental.Notebook.Model(uuid: "notebookUUID", name: "name", notes: [])
                    let model = Experimental.Note.Model(uuid: "uuid", title: "title", content: "content",
                                                        tags: [], notebook: notebookModel, updatedDate: 0,
                                                        createdDate: 13)
                    let expectedMeta = Experimental.Note.Meta(uuid: "uuid", title: "new title", tags: [],
                                                              updated_at: 15,
                                                              created_at: 13)
                    let expectedURL = URL(string: "notebookUUID.qvnotebook/uuid.qvnote/meta.json")!

                    beforeEach {
                        e = Experimental.Note.Evaluator(model: model)
                        e.currentTimestamp = { 15 }
                    }

                    it("has updateFile action with note's meta URL") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.updateFile(url: expectedURL, content: expectedMeta)))
                    }
                }
            }

            context("when receiving changeContent event") {
                beforeEach {
                    event = .changeContent(newContent: "new content")
                }

                it("updates model by changing note content") {
                    expect(e.evaluate(event: event).model.content)
                        .to(equal("new content"))
                }

                it("updates model's updateDate") {
                    e.currentTimestamp = { 16 }
                    expect(e.evaluate(event: event).model.updatedDate)
                        .to(equal(16))
                }

                context("when note is added to notebook") {
                    let notebookModel = Experimental.Notebook.Model(uuid: "notebookUUID", name: "name", notes: [])
                    let model = Experimental.Note.Model(uuid: "uuid", title: "title", content: "content",
                                                        tags: [], notebook: notebookModel, updatedDate: 0,
                                                        createdDate: 16)
                    let expectedContent = Experimental.Note.Content(content: "new content")
                    let expectedURL = URL(string: "notebookUUID.qvnotebook/uuid.qvnote/content.json")!

                    beforeEach {
                        e = Experimental.Note.Evaluator(model: model)
                    }

                    it("has updateFile action with note's content URL") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(.updateFile(url: expectedURL, content: expectedContent)))
                    }
                }
            }

            context("when receiving addTag event") {
                beforeEach {
                    event = .addTag(tag: "tag")
                }

                context("when tag was already added") {
                    let model = Experimental.Note.Model(uuid: "uuid", title: "title",
                                                        content: "content", tags: ["tag"], updatedDate: 0,
                                                        createdDate: 18)

                    beforeEach {
                        e = Experimental.Note.Evaluator(model: model)
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model)
                            .to(equal(model))
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }
                }

                context("when tag is new") {
                    it("updates model by appending tag") {
                        expect(e.evaluate(event: event).model.tags)
                            .to(equal(["tag"]))
                    }

                    it("updates model's updateDate") {
                        e.currentTimestamp = { 18 }
                        expect(e.evaluate(event: event).model.updatedDate)
                            .to(equal(18))
                    }

                    context("when note is added to notebook") {
                        let notebookModel = Experimental.Notebook.Model(uuid: "notebookUUID", name: "name", notes: [])
                        let model = Experimental.Note.Model(uuid: "uuid", title: "title", content: "content",
                                                            tags: [], notebook: notebookModel, updatedDate: 0,
                                                            createdDate: 19)
                        let expectedMeta = Experimental.Note.Meta(uuid: "uuid", title: "title", tags: ["tag"],
                                                                  updated_at: 20,
                                                                  created_at: 19)
                        let expectedURL = URL(string: "notebookUUID.qvnotebook/uuid.qvnote/meta.json")!

                        beforeEach {
                            e = Experimental.Note.Evaluator(model: model)
                            e.currentTimestamp = { 20 }
                        }

                        it("has updateFile action with note's meta URL") {
                            expect(e.evaluate(event: event).actions[0])
                                .to(equal(.updateFile(url: expectedURL, content: expectedMeta)))
                        }
                    }
                }
            }

            context("when receiving removeTag event") {
                context("when that tag exist") {
                    let model = Experimental.Note.Model(uuid: "uuid", title: "title", content: "content",
                                                        tags: ["tag"], updatedDate: 0, createdDate: 20)

                    beforeEach {
                        e = Experimental.Note.Evaluator(model: model)
                        event = .removeTag(tag: "tag")
                    }

                    it("updates model by removing tag") {
                        expect(e.evaluate(event: event).model.tags)
                            .to(beEmpty())
                    }

                    it("updates model's updateDate") {
                        e.currentTimestamp = { 20 }
                        expect(e.evaluate(event: event).model.updatedDate)
                            .to(equal(20))
                    }

                    context("when note is added to notebook") {
                        let notebookModel = Experimental.Notebook.Model(uuid: "notebookUUID", name: "name", notes: [])
                        let model = Experimental.Note.Model(uuid: "uuid", title: "title", content: "content",
                                                            tags: ["tag"], notebook: notebookModel, updatedDate: 0,
                                                            createdDate: 21)
                        let expectedMeta = Experimental.Note.Meta(uuid: "uuid", title: "title", tags: [],
                                                                  updated_at: 22,
                                                                  created_at: 21)
                        let expectedURL = URL(string: "notebookUUID.qvnotebook/uuid.qvnote/meta.json")!

                        beforeEach {
                            e = Experimental.Note.Evaluator(model: model)
                            e.currentTimestamp = { 22 }
                        }

                        it("has updateFile action with note's meta URL") {
                            expect(e.evaluate(event: event).actions[0])
                                .to(equal(.updateFile(url: expectedURL, content: expectedMeta)))
                        }
                    }
                }

                context("when that tag doesnt exist") {
                    beforeEach {
                        event = .removeTag(tag: "tag")
                    }

                    it("doesnt update model") {
                        expect(e.evaluate(event: event).model)
                            .to(equal(model))
                    }

                    it("hasnt got any actions") {
                        expect(e.evaluate(event: event).actions)
                            .to(beEmpty())
                    }
                }
            }
        }
    }
}
