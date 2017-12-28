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
        let error = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])
        let meta = Note.Meta(uuid: "uuid", title: "title", tags: ["tag"], updated_at: 12, created_at: 12)
        let model = Note.Model(meta: meta, content: "content")
        var e: Note.Evaluator!

        beforeEach {
            e = Note.Evaluator(model: model)
        }

        context("when initialized") {
            it("has zero effects") {
                expect(e.effects).to(beEmpty())
            }

            it("has passed model") {
                expect(e.model).to(equal(model))
            }
        }

        describe("-evaluate:") {
            var event: Note.Event!

            context("when receiving changeTitle event") {
                beforeEach {
                    event = .changeTitle("new title")
                    e.currentTimestamp = { 15 }
                    e = e.evaluate(event: event)
                }

                it("updates model by changing title and updatedDate") {
                    expect(e.model).to(equalDiff(
                        Note.Model(meta: Note.Meta(uuid: "uuid", title: "new title", tags: ["tag"],
                                                   updated_at: 15, created_at: 12), content: "content")
                    ))
                }

                it("doesnt have any effects") {
                    expect(e.effects).to(beEmpty())
                }

                context("when note is added to notebook") {
                    beforeEach {
                        let notebook = Notebook.Meta(uuid: "notebookUUID", name: "name")
                        let model = Note.Model(meta: meta, content: "content", notebook: notebook)
                        e = Note.Evaluator(model: model)
                        e.currentTimestamp = { 15 }
                        e = e.evaluate(event: event)
                    }

                    it("has updateTitle effect") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle(note: Note.Meta(uuid: meta.uuid, title: "new title", tags: meta.tags,
                                                         updated_at: 15, created_at: meta.created_at),
                                         url: URL(string: "notebookUUID.qvnotebook/uuid.qvnote/meta.json")!,
                                         oldTitle: "title")
                        ]))
                    }
                }
            }

            context("when receiving changeContent event") {
                beforeEach {
                    event = .changeContent("new content")
                    e.currentTimestamp = { 16 }
                    e = e.evaluate(event: event)
                }

                it("updates model by changing content and updatedDate") {
                    expect(e.model).to(equalDiff(
                        Note.Model(meta: Note.Meta(uuid: "uuid", title: "title", tags: ["tag"],
                                                   updated_at: 16, created_at: 12), content: "new content")
                    ))
                }

                it("doesnt have any effects") {
                    expect(e.effects).to(beEmpty())
                }

                context("when note is added to notebook") {
                    beforeEach {
                        let notebook = Notebook.Meta(uuid: "notebookUUID", name: "name")
                        let model = Note.Model(meta: meta, content: "content", notebook: notebook)
                        e = Note.Evaluator(model: model)
                        e = e.evaluate(event: event)
                    }

                    it("has updateContent effect") {
                        expect(e.effects).to(equalDiff([
                            .updateContent(content: "new content",
                                           url: URL(string: "notebookUUID.qvnotebook/uuid.qvnote/content.json")!,
                                           oldContent: "content")
                        ]))
                    }
                }
            }

            context("when receiving addTag event") {
                context("when tag was already added") {
                    beforeEach {
                        event = .addTag("tag")
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }

                context("when tag is new") {
                    beforeEach {
                        event = .addTag("new tag")
                        e.currentTimestamp = { 18 }
                        e = e.evaluate(event: event)
                    }

                    it("updates model by appending tag and updating updateDate") {
                        expect(e.model).to(equalDiff(
                            Note.Model(meta: Note.Meta(uuid: "uuid", title: "title", tags: ["tag", "new tag"],
                                                       updated_at: 18, created_at: 12), content: "content")
                        ))
                    }

                    it("doesnt have any effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    context("when note is added to notebook") {
                        beforeEach {
                            let notebook = Notebook.Meta(uuid: "notebookUUID", name: "name")
                            let model = Note.Model(meta: meta, content: "content", notebook: notebook)
                            e = Note.Evaluator(model: model)
                            e.currentTimestamp = { 20 }
                            e = e.evaluate(event: event)
                        }

                        it("has addTag effect") {
                            expect(e.effects).to(equalDiff([
                                .addTag("new tag",
                                        note: Note.Meta(uuid: meta.uuid, title: meta.title,
                                                        tags: ["tag", "new tag"], updated_at: 20,
                                                        created_at: meta.created_at),
                                        url: URL(string: "notebookUUID.qvnotebook/uuid.qvnote/meta.json")!)
                            ]))
                        }
                    }
                }
            }

            context("when receiving removeTag event") {
                context("when that tag exist") {
                    beforeEach {
                        event = .removeTag("tag")
                        e.currentTimestamp = { 20 }
                        e = e.evaluate(event: event)
                    }

                    it("updates model by removing tag and updating updatedDate") {
                        expect(e.model).to(equalDiff(
                            Note.Model(meta: Note.Meta(uuid: "uuid", title: "title", tags: [],
                                                       updated_at: 20, created_at: 12), content: "content")
                        ))
                    }

                    it("doesnt have any effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    context("when note is added to notebook") {
                        beforeEach {
                            let notebook = Notebook.Meta(uuid: "notebookUUID", name: "name")
                            let model = Note.Model(meta: meta, content: "content", notebook: notebook)
                            e = Note.Evaluator(model: model)
                            e.currentTimestamp = { 22 }
                            e = e.evaluate(event: event)
                        }

                        it("has removeTag effect") {
                            expect(e.effects).to(equalDiff([
                                .removeTag("tag",
                                           note: Note.Meta(uuid: meta.uuid, title: meta.title,
                                                        tags: [], updated_at: 22, created_at: meta.created_at),
                                           url: URL(string: "notebookUUID.qvnotebook/uuid.qvnote/meta.json")!)
                            ]))
                        }
                    }
                }

                context("when that tag doesnt exist") {
                    beforeEach {
                        event = .removeTag("not existing tag")
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }
            }

            context("when receiving didChangeTitle event") {
                context("when successfully changes title") {
                    beforeEach {
                        event = .didChangeTitle(oldTitle: "old title", error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to change title") {
                    beforeEach {
                        event = .didChangeTitle(oldTitle: "old title", error: error)
                        e = e.evaluate(event: event)
                    }

                    it("updates model by setting title back to the old") {
                        expect(e.model).to(equalDiff(
                            Note.Model(meta: Note.Meta(uuid: meta.uuid, title: "old title",
                                                       tags: meta.tags, updated_at: meta.updated_at,
                                                       created_at: meta.created_at),
                                       content: "content")
                        ))
                    }
                }
            }

            context("when receiving didChangeContent event") {
                context("when successfully changes content") {
                    beforeEach {
                        event = .didChangeContent(oldContent: "old content", error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to change content") {
                    beforeEach {
                        event = .didChangeContent(oldContent: "old content", error: error)
                        e = e.evaluate(event: event)
                    }

                    it("updates model by setting content back to the old") {
                        expect(e.model).to(equalDiff(
                            Note.Model(meta: Note.Meta(uuid: meta.uuid, title: meta.title,
                                                       tags: meta.tags, updated_at: meta.updated_at,
                                                       created_at: meta.created_at),
                                       content: "old content")
                        ))
                    }
                }
            }

            context("when receiving didAddTag event") {
                context("when successfully adds tag") {
                    beforeEach {
                        event = .didAddTag("tag", error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to add tag") {
                    beforeEach {
                        event = .didAddTag("tag", error: error)
                        e = e.evaluate(event: event)
                    }

                    it("removes tag from the model") {
                        expect(e.model).to(equalDiff(
                            Note.Model(meta: Note.Meta(uuid: meta.uuid, title: meta.title,
                                                       tags: [], updated_at: meta.updated_at,
                                                       created_at: meta.created_at),
                                       content: "content")
                        ))
                    }
                }
            }

            context("when receiving didRemoveTag event") {
                context("when successfuly removes tag") {
                    beforeEach {
                        event = .didRemoveTag("removed tag", error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to remove tag") {
                    beforeEach {
                        event = .didRemoveTag("removed tag", error: error)
                        e = e.evaluate(event: event)
                    }

                    it("adds removed tag back to model") {
                        expect(e.model).to(equalDiff(
                            Note.Model(meta: Note.Meta(uuid: meta.uuid, title: meta.title,
                                                       tags: ["tag", "removed tag"], updated_at: meta.updated_at,
                                                       created_at: meta.created_at),
                                       content: "content")
                        ))
                    }
                }
            }
        }
    }
}
