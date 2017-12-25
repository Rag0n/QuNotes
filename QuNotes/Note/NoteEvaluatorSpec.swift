//
//  NoteEvaluatorSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 16.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Core

class NoteEvaluatorSpec: QuickSpec {
    override func spec() {
        var e: Note.Evaluator!
        let note = NoteDummy.note
        let content = NoteDummy.content
        let isNew = NoteDummy.isNew
        let model = NoteDummy.model
        let error = NoteDummy.error

        beforeEach {
            e = Note.Evaluator(note: note, content: content, isNew: isNew)
        }

        describe("-evaluate:ViewEvent") {
            var event: Note.ViewEvent!

            context("when receiving didLoad event") {
                beforeEach {
                    event = .didLoad
                }

                context("when note is new") {
                    beforeEach {
                        e = Note.Evaluator(note: note, content: content, isNew: true)
                        e = e.evaluate(event: event)
                    }

                    it("has updateTitle, showTags and focusOnTitle effects") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle(title: "title"),
                            .showTags(tags: ["tag"]),
                            .focusOnTitle
                        ]))
                    }
                }

                context("when note is not new") {
                    beforeEach {
                        e = Note.Evaluator(note: note, content: content, isNew: false)
                        e = e.evaluate(event: event)
                    }

                    it("has updateTitle and showTags effects") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle(title: "title"),
                            .showTags(tags: ["tag"])
                        ]))
                    }
                }
            }

            context("when receiving changeContent event") {
                beforeEach {
                    event = .changeContent(newContent: "newContent")
                    e = e.evaluate(event: event)
                }

                it("has updateContent action") {
                    expect(e.actions).to(equalDiff([
                        .updateContent(content: "newContent")
                    ]))
                }

                it("has updateContent effect") {
                    expect(e.effects).to(equalDiff([
                        .updateContent(content: "newContent")
                    ]))
                }

                it("updates content in model") {
                    expect(e.model).to(equalDiff(
                        NoteDummy.model(fromModel: model, content: "newContent")
                    ))
                }
            }

            context("when receiving changeTitle event") {
                beforeEach {
                    event = .changeTitle(newTitle: "newTitle")
                    e = e.evaluate(event: event)
                }

                it("has updateTitle action") {
                    expect(e.actions).to(equalDiff([
                        .updateTitle(title: "newTitle")
                    ]))
                }

                it("has updateTitle effect") {
                    expect(e.effects).to(equalDiff([
                        .updateTitle(title: "newTitle")
                    ]))
                }

                it("updates title in model") {
                    expect(e.model).to(equalDiff(
                        NoteDummy.model(fromModel: model, title: "newTitle")
                    ))
                }
            }

            context("when receiving delete event") {
                beforeEach {
                    event = .delete
                    e = e.evaluate(event: event)
                }

                it("has delete action") {
                    expect(e.actions).to(equalDiff([
                        .deleteNote
                    ]))
                }
            }

            context("when receiving addTag event") {
                beforeEach {
                    event = .addTag(tag: "new tag")
                    e = e.evaluate(event: event)
                }

                it("has addTag action") {
                    expect(e.actions).to(equalDiff([
                        .addTag(tag: "new tag")
                    ]))
                }

                it("has addTag effect") {
                    expect(e.effects).to(equalDiff([
                        .addTag(tag: "new tag")
                    ]))
                }

                it("adds tag to model") {
                    expect(e.model).to(equalDiff(
                        NoteDummy.model(fromModel: model, tags: ["tag", "new tag"])
                    ))
                }
            }

            context("when receiving removeTag event") {
                beforeEach {
                    event = .removeTag(tag: "tag")
                    e = e.evaluate(event: event)
                }

                it("has removeTag action") {
                    expect(e.actions).to(equalDiff([
                        .removeTag(tag: "tag")
                    ]))
                }

                it("has removeTag effect") {
                    expect(e.effects).to(equalDiff([
                        .removeTag(tag: "tag")
                    ]))
                }

                it("removes tag from model") {
                    expect(e.model).to(equalDiff(
                        NoteDummy.model(fromModel: model, tags: [])
                    ))
                }
            }
        }

        describe("-evaluate:CoordinatorEvent") {
            var event: Note.CoordinatorEvent!

            context("when receiving didDeleteNote event") {
                context("when successfuly deletes note") {
                    beforeEach {
                        event = .didDeleteNote(error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("has finish action") {
                        expect(e.actions).to(equalDiff([
                            .finish
                        ]))
                    }
                }

                context("when fails to delete note") {
                    beforeEach {
                        event = .didDeleteNote(error: error)
                        e = e.evaluate(event: event)
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to delete note", message: NoteDummy.errorMessage)
                        ]))
                    }
                }
            }

            context("when receiving didUpdateTitle event") {
                context("when successfully updates title") {
                    beforeEach {
                        event = .didUpdateTitle(oldTitle: "old title", error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }

                context("when fails to update title") {
                    beforeEach {
                        event = .didUpdateTitle(oldTitle: "old title", error: error)
                        e = e.evaluate(event: event)
                    }

                    it("updates model with old title") {
                        expect(e.model).to(equalDiff(
                            NoteDummy.model(fromModel: model, title: "old title")
                        ))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to update title", message: NoteDummy.errorMessage)
                        ]))
                    }

                    it("has updateTitle effect") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle(title: "old title")
                        ]))
                    }
                }
            }

            context("when receiving didUpdateContent event") {
                context("when successfully updates content") {
                    beforeEach {
                        event = .didUpdateContent(oldContent: "old content", error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }

                context("when fails to update content") {
                    beforeEach {
                        event = .didUpdateContent(oldContent: "old content", error: error)
                        e = e.evaluate(event: event)
                    }

                    it("updates model with old content") {
                        expect(e.model).to(equalDiff(
                            NoteDummy.model(fromModel: model, content: "old content")
                        ))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to update content", message: NoteDummy.errorMessage)
                            ]))
                    }

                    it("has updateContent effect") {
                        expect(e.effects).to(equalDiff([
                            .updateContent(content: "old content")
                        ]))
                    }
                }
            }

            context("when receiving didAddTag event") {
                context("when successfully adds tag") {
                    beforeEach {
                        event = .didAddTag(tag: "tag", error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }

                context("when fails to add tag") {
                    beforeEach {
                        event = .didAddTag(tag: "tag", error: error)
                        e = e.evaluate(event: event)
                    }

                    it("removes tag from model") {
                        expect(e.model).to(equalDiff(
                            NoteDummy.model(fromModel: model, tags: [])
                        ))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to add tag", message: NoteDummy.errorMessage)
                        ]))
                    }

                    it("has removeTag effect") {
                        expect(e.effects).to(equalDiff([
                            .removeTag(tag: "tag")
                        ]))
                    }
                }
            }

            context("when receiving didRemoveTag event") {
                context("when successfully removes tag") {
                    beforeEach {
                        event = .didRemoveTag(tag: "removed tag", error: nil)
                        e = e.evaluate(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }

                context("when fails to remove tag") {
                    beforeEach {
                        event = .didRemoveTag(tag: "removed tag", error: error)
                        e = e.evaluate(event: event)
                    }

                    it("adds tag back to model") {
                        expect(e.model).to(equalDiff(
                            NoteDummy.model(fromModel: model, tags: ["tag", "removed tag"])
                        ))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to remove tag", message: NoteDummy.errorMessage)
                        ]))
                    }

                    it("has addTag effect") {
                        expect(e.effects).to(equalDiff([
                            .addTag(tag: "removed tag")
                        ]))
                    }
                }
            }
        }
    }
}

enum NoteDummy {
    static var isNew: Bool {
        return false
    }

    static var note: Core.Note.Meta {
        return Core.Note.Meta(uuid: "uuid", title: "title", tags: ["tag"], updated_at: 14, created_at: 14)
    }

    static var content: String {
        return "content"
    }

    static var model: Note.Model {
        return Note.Model(title: "title", tags: ["tag"], content: "content", isNew: false)
    }

    static var error: Error {
        return NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
    }

    static var errorMessage: String {
        return "message"
    }

    static func model(fromModel model: Note.Model, title: String? = nil,
                      tags: [String]? = nil, content: String? = nil, isNew: Bool? = nil) -> Note.Model {
        return Note.Model(title: title ?? model.title,
                          tags: tags ?? model.tags,
                          content: content ?? model.content,
                          isNew: isNew ?? model.isNew)
    }
}
