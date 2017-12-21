//
//  NoteEvaluatorSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 16.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result
import Core

class NoteEvaluatorSpec: QuickSpec {
    override func spec() {
        var e: Note.Evaluator!
        let note = Core.Note.Meta(uuid: "uuid", title: "title", tags: ["tag"], updated_at: 14, created_at: 14)
        let content = "content"
        let isNew = false
        let underlyingError = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])
        let error = AnyError(underlyingError)

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
                        Note.Model(title: note.title, tags: note.tags, content: "newContent", isNew: isNew)
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
                        Note.Model(title: "newTitle", tags: note.tags, content: content, isNew: isNew)
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
                        Note.Model(title: note.title, tags: ["tag", "new tag"], content: content, isNew: isNew)
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
                        Note.Model(title: note.title, tags: [], content: content, isNew: isNew)
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
                            .showError(title: "Failed to delete note", message: error.localizedDescription)
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
                        expect(e.model).to(equalDiff(
                            Note.Model(title: note.title, tags: note.tags, content: content, isNew: isNew)
                        ))
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
                            Note.Model(title: note.title, tags: [], content: content, isNew: isNew)
                        ))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to add tag", message: error.localizedDescription)
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
                        expect(e.model).to(equalDiff(
                            Note.Model(title: note.title, tags: note.tags, content: content, isNew: isNew)
                        ))
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
                            Note.Model(title: note.title, tags: ["tag", "removed tag"], content: content, isNew: isNew)
                        ))
                    }

                    it("has showError action") {
                        expect(e.actions).to(equalDiff([
                            .showError(title: "Failed to remove tag", message: error.localizedDescription)
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
//            let updatedNote = UseCase.Note(createdDate: 2, updatedDate: 3, content: "new content", title: "new title", uuid: "uuid", tags: ["added tag"])
//
//            context("when receiving didUpdateTitle event") {
//                context("when successfully updates note's title") {
//                    beforeEach {
//                        event = .didUpdateTitle(result: Result(updatedNote))
//                    }
//
//                    it("has updateTitle effect") {
//                        expect(e.evaluate(event: event).effects[0])
//                            .to(equal(.updateTitle(title: "new title")))
//                    }
//
//                    it("updates model with updated note") {
//                        expect(e.evaluate(event: event).model.note.title)
//                            .to(equal("new title"))
//                    }
//                }
//
//                context("when fails to update note's title") {
//                    beforeEach {
//                        event = .didUpdateTitle(result: Result(error: error))
//                    }
//
//                    it("has updateTitle effect") {
//                        expect(e.evaluate(event: event).effects[0])
//                            .to(equal(.updateTitle(title: "title")))
//                    }
//
//                    it("has showError action") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(.showError(title: "Failed to update note's title", message: "message")))
//                    }
//                }
//            }
//
//            context("when receiving didUpdateContent event") {
//                context("when successfully updates note's content") {
//                    beforeEach {
//                        event = .didUpdateContent(result: Result(updatedNote))
//                    }
//
//                    it("has updateContent effect") {
//                        expect(e.evaluate(event: event).effects[0])
//                            .to(equal(.updateContent(content: "new content")))
//                    }
//
//                    it("updates model with updated note") {
//                        expect(e.evaluate(event: event).model.note.content)
//                            .to(equal("new content"))
//                    }
//                }
//
//                context("when fails to update note's content") {
//                    beforeEach {
//                        event = .didUpdateContent(result: Result(error: error))
//                    }
//
//                    it("has updateContent effect") {
//                        expect(e.evaluate(event: event).effects[0])
//                            .to(equal(.updateContent(content: "content")))
//                    }
//
//                    it("has showError action") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(.showError(title: "Failed to update note's content", message: "message")))
//                    }
//                }
//            }
//
//            context("when receiving didDeleteNote event") {
//                context("when successfully deletes note") {
//                    beforeEach {
//                        event = .didDeleteNote(error: nil)
//                    }
//
//                    it("has finish action") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(UI.Note.Action.finish))
//                    }
//                }
//
//                context("when fails to delete note") {
//                    beforeEach {
//                        event = .didDeleteNote(error: error)
//                    }
//
//                    it("has showError action") {
//                        expect(e.evaluate(event: event).actions[0])
//                            .to(equal(.showError(title: "Failed to delete note", message: "message")))
//                    }
//                }
//            }
//        }
//    }
    }
}
