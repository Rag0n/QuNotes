//
//  NoteSpec.swift
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
        let error = AnyError(NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"]))
        let meta = Note.Meta(uuid: "uuid", title: "title", tags: ["tag"], updated_at: 12, created_at: 12)
        let content = Note.Content(title: "title", cells: [Note.Cell(type: .markdown, data: "content")])
        let model = Note.Model(meta: meta, content: content)
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

        describe("-evaluating:") {
            var event: Note.Event!

            context("when receiving loadContent event") {
                beforeEach {
                    event = .loadContent
                    e = e.evaluating(event: event)
                }

                context("when note is added to notebook") {
                    beforeEach {
                        let notebook = Notebook.Meta(uuid: "notebookUUID", name: "name")
                        let model = Note.Model(meta: meta, content: content, notebook: notebook)
                        e = Note.Evaluator(model: model)
                        e = e.evaluating(event: event)
                    }

                    it("has readContent effect") {
                        expect(e.effects).to(equalDiff([
                            .readContent(url: Dummy.url("notebookUUID.qvnotebook/uuid.qvnote/content.json"))
                        ]))
                    }
                }

                context("when note is not added to notebook") {
                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }
            }

            context("when receiving didReadContent event") {
                context("when successfully reads content") {
                    let content = Note.Content(title: "title", cells: [Note.Cell(type: .markdown, data: "new content")])

                    beforeEach {
                        event = .didReadContent(Result(value: content))
                        e = e.evaluating(event: event)
                    }

                    it("updates model with new content") {
                        expect(e.model).to(equalDiff(
                            Note.Model(meta: meta, content: content)
                        ))
                    }

                    it("has didLoadContent effect") {
                        expect(e.effects).to(equalDiff([
                            .didLoadContent(content)
                        ]))
                    }
                }

                context("when fails to read content") {
                    beforeEach {
                        event = .didReadContent(Result(error: error))
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("has handleError effect") {
                        expect(e.effects).to(equalDiff([
                            .handleError(title: "Failed to load content", message: "message")
                        ]))
                    }
                }
            }

            context("when receiving changeTitle event") {
                beforeEach {
                    event = .changeTitle("new title")
                    e.currentTimestamp = { 15 }
                    e = e.evaluating(event: event)
                }

                it("updates model by changing title, content's title and updatedDate") {
                    expect(e.model).to(equalDiff(
                        Dummy.model(fromModel: model, title: "new title", updated_at: 15,
                                    content: Note.Content(title: "new title", cells: content.cells))
                    ))
                }

                it("doesnt have any effects") {
                    expect(e.effects).to(beEmpty())
                }

                context("when note is added to notebook") {
                    beforeEach {
                        let notebook = Notebook.Meta(uuid: "notebookUUID", name: "name")
                        let model = Note.Model(meta: meta, content: content, notebook: notebook)
                        e = Note.Evaluator(model: model)
                        e.currentTimestamp = { 15 }
                        e = e.evaluating(event: event)
                    }

                    it("has updateTitle and updateContnet effects") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle(note: Dummy.meta(fromMeta: meta, title: "new title", updated_at: 15),
                                         url: Dummy.url("notebookUUID.qvnotebook/uuid.qvnote/meta.json"),
                                         oldTitle: "title"),
                            .updateContent(content: Note.Content(title: "new title", cells: content.cells),
                                           url: Dummy.url("notebookUUID.qvnotebook/uuid.qvnote/content.json"),
                                           oldContent: content)
                        ]))
                    }
                }
            }

            context("when receiving changeCells event") {
                let newCells = [
                    Note.Cell(type: .markdown, data: "new cell")
                ]

                beforeEach {
                    event = .changeCells(newCells)
                    e.currentTimestamp = { 16 }
                    e = e.evaluating(event: event)
                }

                it("updates model by changing content's cells and updatedDate") {
                    expect(e.model).to(equalDiff(
                        Dummy.model(fromModel: model, updated_at: 16,
                                    content: Note.Content(title: meta.title, cells: newCells))
                    ))
                }

                it("doesnt have any effects") {
                    expect(e.effects).to(beEmpty())
                }

                context("when note is added to notebook") {
                    beforeEach {
                        let notebook = Notebook.Meta(uuid: "notebookUUID", name: "name")
                        let model = Note.Model(meta: meta, content: content, notebook: notebook)
                        e = Note.Evaluator(model: model)
                        e = e.evaluating(event: event)
                    }

                    it("has updateContent effect") {
                        expect(e.effects).to(equalDiff([
                            .updateContent(content:  Note.Content(title: meta.title, cells: newCells),
                                           url: Dummy.url("notebookUUID.qvnotebook/uuid.qvnote/content.json"),
                                           oldContent: content)
                        ]))
                    }
                }
            }

            context("when receiving addTag event") {
                context("when tag was already added") {
                    beforeEach {
                        event = .addTag("tag")
                        e = e.evaluating(event: event)
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
                        e = e.evaluating(event: event)
                    }

                    it("updates model by appending tag and updating updateDate") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, tags: ["tag", "new tag"], updated_at: 18)
                        ))
                    }

                    it("doesnt have any effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    context("when note is added to notebook") {
                        beforeEach {
                            let notebook = Notebook.Meta(uuid: "notebookUUID", name: "name")
                            let model = Note.Model(meta: meta, content: content, notebook: notebook)
                            e = Note.Evaluator(model: model)
                            e.currentTimestamp = { 20 }
                            e = e.evaluating(event: event)
                        }

                        it("has addTag effect") {
                            expect(e.effects).to(equalDiff([
                                .addTag("new tag",
                                        note: Dummy.meta(fromMeta: meta, tags: ["tag", "new tag"], updated_at: 20),
                                        url: Dummy.url("notebookUUID.qvnotebook/uuid.qvnote/meta.json"))
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
                        e = e.evaluating(event: event)
                    }

                    it("updates model by removing tag and updating updatedDate") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, tags: [], updated_at: 20)
                        ))
                    }

                    it("doesnt have any effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    context("when note is added to notebook") {
                        beforeEach {
                            let notebook = Notebook.Meta(uuid: "notebookUUID", name: "name")
                            let model = Note.Model(meta: meta, content: content, notebook: notebook)
                            e = Note.Evaluator(model: model)
                            e.currentTimestamp = { 22 }
                            e = e.evaluating(event: event)
                        }

                        it("has removeTag effect") {
                            expect(e.effects).to(equalDiff([
                                .removeTag("tag",
                                           note: Dummy.meta(fromMeta: meta, tags: [], updated_at: 22),
                                           url: Dummy.url("notebookUUID.qvnotebook/uuid.qvnote/meta.json"))
                            ]))
                        }
                    }
                }

                context("when that tag doesnt exist") {
                    beforeEach {
                        event = .removeTag("not existing tag")
                        e = e.evaluating(event: event)
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
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to change title") {
                    beforeEach {
                        event = .didChangeTitle(oldTitle: "old title", error: error)
                        e = e.evaluating(event: event)
                    }

                    it("updates model by setting title back to the old") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, title: "old title",
                                        content: Note.Content(title: "old title", cells: content.cells))
                        ))
                    }
                }
            }

            context("when receiving didChangeContent event") {
                let oldContent = Note.Content(title: model.meta.title,
                                              cells: [Note.Cell(type: .markdown, data: "old content")])

                context("when successfully changes content") {
                    beforeEach {
                        event = .didChangeContent(oldContent: oldContent, error: nil)
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to change content") {
                    beforeEach {
                        event = .didChangeContent(oldContent: oldContent, error: error)
                        e = e.evaluating(event: event)
                    }

                    it("updates model by setting content back to the old") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, content: oldContent)
                        ))
                    }
                }
            }

            context("when receiving didAddTag event") {
                context("when successfully adds tag") {
                    beforeEach {
                        event = .didAddTag("tag", error: nil)
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to add tag") {
                    beforeEach {
                        event = .didAddTag("tag", error: error)
                        e = e.evaluating(event: event)
                    }

                    it("removes tag from the model") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, tags: [])
                        ))
                    }
                }
            }

            context("when receiving didRemoveTag event") {
                context("when successfuly removes tag") {
                    beforeEach {
                        event = .didRemoveTag("removed tag", error: nil)
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }

                context("when fails to remove tag") {
                    beforeEach {
                        event = .didRemoveTag("removed tag", error: error)
                        e = e.evaluating(event: event)
                    }

                    it("adds removed tag back to model") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, tags: ["tag", "removed tag"])
                        ))
                    }
                }
            }
        }
    }
}

private enum Dummy {
    static func meta(fromMeta meta: Note.Meta, title: String? = nil, tags: [String]? = nil,
                     updated_at: TimeInterval? = nil, created_at: TimeInterval? = nil) -> Note.Meta {
        return Note.Meta(uuid: meta.uuid,
                         title: title ?? meta.title,
                         tags: tags ?? meta.tags,
                         updated_at: updated_at ?? meta.updated_at,
                         created_at: created_at ?? meta.created_at)
    }

    static func model(fromModel model: Note.Model, title: String? = nil, tags: [String]? = nil,
                      updated_at: TimeInterval? = nil, created_at: TimeInterval? = nil,
                      content: Note.Content? = nil, notebook: Notebook.Meta? = nil) -> Note.Model {
        let newMeta = meta(fromMeta: model.meta, title: title, tags: tags,
                           updated_at: updated_at, created_at: created_at)
        return Note.Model(meta: newMeta,
                          content: content ?? model.content,
                          notebook: notebook ?? model.notebook)
    }

    static func url(_ string: String) -> DynamicBaseURL {
        return DynamicBaseURL(url: URL(string: string)!)
    }
}
