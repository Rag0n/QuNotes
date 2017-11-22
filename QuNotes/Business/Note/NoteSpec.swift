//
//  NoteSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble

class NoteExperimantalSpec: QuickSpec {
    override func spec() {
        let meta = Note.Meta(uuid: "uuid", title: "title", tags: ["tag"], updated_at: 12, created_at: 12)
        let model = Note.Model(meta: meta, content: "content", notebook: nil)
        var e: Note.Evaluator!

        beforeEach {
            e = Note.Evaluator(model: model)
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
            var event: Note.InputEvent!

            context("when receiving changeTitle event") {
                beforeEach {
                    event = .changeTitle(newTitle: "new title")
                    e.currentTimestamp = { 15 }
                    e = e.evaluate(event: event)
                }

                it("updates model by changing title and updatedDate") {
                    expect(e.model).to(equalDiff(
                        Note.Model(uuid: "uuid", title: "new title", content: "content", tags: ["tag"],
                                   notebook: nil, updatedDate: 15, createdDate: 12)
                    ))
                }

                context("when note is added to notebook") {
                    beforeEach {
                        let notebook = Notebook.Model(uuid: "notebookUUID", name: "name", notes: [])
                        let model = Note.Model(meta: meta, content: "content", notebook: notebook)
                        e = Note.Evaluator(model: model)
                        e.currentTimestamp = { 15 }
                        e = e.evaluate(event: event)
                    }

                    it("has updateFile action with meta & meta URL") {
                        expect(e.actions).to(equalDiff([
                            .updateFile(url: URL(string: "notebookUUID.qvnotebook/uuid.qvnote/meta.json")!,
                                        content: Note.Meta(uuid: "uuid", title: "new title", tags: ["tag"],
                                                           updated_at: 15, created_at: 12))
                        ]))
                    }
                }
            }

            context("when receiving changeContent event") {
                beforeEach {
                    event = .changeContent(newContent: "new content")
                    e.currentTimestamp = { 16 }
                    e = e.evaluate(event: event)
                }

                it("updates model by changing content and updatedDate") {
                    expect(e.model).to(equalDiff(
                        Note.Model(uuid: "uuid", title: "title", content: "new content", tags: ["tag"],
                                   notebook: nil, updatedDate: 16, createdDate: 12)
                    ))
                }

                context("when note is added to notebook") {
                    beforeEach {
                        let notebook = Notebook.Model(uuid: "notebookUUID", name: "name", notes: [])
                        let model = Note.Model(meta: meta, content: "content", notebook: notebook)
                        e = Note.Evaluator(model: model)
                        e = e.evaluate(event: event)
                    }

                    it("has updateFile action with content & content URL") {
                        expect(e.actions).to(equalDiff([
                            .updateFile(url: URL(string: "notebookUUID.qvnotebook/uuid.qvnote/content.json")!,
                                        content: Note.Content(content: "new content"))
                        ]))
                    }
                }
            }

            context("when receiving addTag event") {
                context("when tag was already added") {
                    beforeEach {
                        event = .addTag(tag: "tag")
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }

                context("when tag is new") {
                    beforeEach {
                        event = .addTag(tag: "new tag")
                        e.currentTimestamp = { 18 }
                        e = e.evaluate(event: event)
                    }

                    it("updates model by appending tag and updating updateDate") {
                        expect(e.model).to(equalDiff(
                            Note.Model(uuid: "uuid", title: "title", content: "content", tags: ["tag", "new tag"],
                                       notebook: nil, updatedDate: 18, createdDate: 12)
                        ))
                    }

                    context("when note is added to notebook") {
                        beforeEach {
                            let notebook = Notebook.Model(uuid: "notebookUUID", name: "name", notes: [])
                            let model = Note.Model(meta: meta, content: "content", notebook: notebook)
                            e = Note.Evaluator(model: model)
                            e.currentTimestamp = { 20 }
                            e = e.evaluate(event: event)
                        }

                        it("has updateFile action with meta & meta URL") {
                            expect(e.actions).to(equalDiff([
                                .updateFile(url: URL(string: "notebookUUID.qvnotebook/uuid.qvnote/meta.json")!,
                                            content: Note.Meta(uuid: "uuid", title: "title", tags: ["tag", "new tag"],
                                                               updated_at: 20, created_at: 12))
                            ]))
                        }
                    }
                }
            }

            context("when receiving removeTag event") {
                context("when that tag exist") {
                    beforeEach {
                        event = .removeTag(tag: "tag")
                        e.currentTimestamp = { 20 }
                        e = e.evaluate(event: event)
                    }

                    it("updates model by removing tag and updating updatedDate") {
                        expect(e.model).to(equalDiff(
                            Note.Model(uuid: "uuid", title: "title", content: "content", tags: [],
                                       notebook: nil, updatedDate: 20, createdDate: 12)
                        ))
                    }

                    context("when note is added to notebook") {
                        beforeEach {
                            let notebook = Notebook.Model(uuid: "notebookUUID", name: "name", notes: [])
                            let model = Note.Model(meta: meta, content: "content", notebook: notebook)
                            e = Note.Evaluator(model: model)
                            e.currentTimestamp = { 22 }
                            e = e.evaluate(event: event)
                        }

                        it("has updateFile action with meta & meta URL") {
                            expect(e.actions).to(equalDiff([
                                .updateFile(url: URL(string: "notebookUUID.qvnotebook/uuid.qvnote/meta.json")!,
                                            content: Note.Meta(uuid: "uuid", title: "title", tags: [],
                                                               updated_at: 22, created_at: 12))
                            ]))
                        }
                    }
                }

                context("when that tag doesnt exist") {
                    beforeEach {
                        event = .removeTag(tag: "not existing tag")
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }
            }
        }
    }
}
