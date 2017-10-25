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

class NoteEvaluatorSpec: QuickSpec {
    override func spec() {
        let note = Note(createdDate: 1, updatedDate: 2, content: "content", title: "title", uuid: "uuid", tags: ["tag"])
        let e = UI.Note.Evaluator(withNote: note)
        let underlyingError = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])
        let error = AnyError(underlyingError)

        describe("-evaluate:ViewControllerEvent:") {
            var event: UI.Note.ViewControllerEvent!

            context("when receiving didLoad event") {
                beforeEach {
                    event = .didLoad
                }

                it("has updateTitle effect") {
                    expect(e.evaluate(event: event).effects[0])
                        .to(equal(.updateTitle(title: "title")))
                }

                it("has updateContent effect") {
                    expect(e.evaluate(event: event).effects[1])
                        .to(equal(.updateContent(content: "content")))
                }

                it("has showTags effect") {
                    expect(e.evaluate(event: event).effects[2])
                        .to(equal(.showTags(tags: ["tag"])))
                }
            }

            context("when receiving changeContent event") {
                beforeEach {
                    event = .changeContent(newContent: "newContent")
                }

                it("has updateContent action") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.updateContent(content: "newContent")))
                }
            }

            context("when receiving changeTitle event") {
                beforeEach {
                    event = .changeTitle(newTitle: "newTitle")
                }

                it("has updateTitle action") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.updateTitle(title: "newTitle")))
                }
            }

            context("when receiving delete event") {
                beforeEach {
                    event = .delete
                }

                it("has delete action") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(UI.Note.Action.deleteNote))
                }
            }

            context("when receiving addTag event") {
                beforeEach {
                    event = .addTag(tag: "new tag")
                }

                it("has addTag action") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.addTag(tag: "new tag")))
                }
            }

            context("when receiving removeTag event") {
                beforeEach {
                    event = .removeTag(tag: "tag")
                }

                it("has removeTag action") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.removeTag(tag: "tag")))
                }
            }
        }

        describe("-evaluate:CoordinatorEvent:") {
            var event: UI.Note.CoordinatorEvent!
            let updatedNote = Note(createdDate: 2, updatedDate: 3, content: "new content", title: "new title", uuid: "uuid", tags: ["added tag"])

            context("when receiving didUpdateTitle event") {
                context("when successfully updates note's title") {
                    beforeEach {
                        event = .didUpdateTitle(result: Result(updatedNote))
                    }

                    it("has updateTitle effect") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateTitle(title: "new title")))
                    }

                    it("updates model with updated note") {
                        expect(e.evaluate(event: event).model.note.title)
                            .to(equal("new title"))
                    }
                }

                context("when fails to update note's title") {
                    beforeEach {
                        event = .didUpdateTitle(result: Result(error: error))
                    }

                    it("has updateTitle effect") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateTitle(title: "title")))
                    }

                    it("has showError effect") {
                        expect(e.evaluate(event: event).effects[1])
                            .to(equal(.showError(error: "Failed to update note's title", message: "message")))
                    }
                }
            }

            context("when receiving didUpdateContent event") {
                context("when successfully updates note's content") {
                    beforeEach {
                        event = .didUpdateContent(result: Result(updatedNote))
                    }

                    it("has updateContent effect") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateContent(content: "new content")))
                    }

                    it("updates model with updated note") {
                        expect(e.evaluate(event: event).model.note.content)
                            .to(equal("new content"))
                    }
                }

                context("when fails to update note's content") {
                    beforeEach {
                        event = .didUpdateContent(result: Result(error: error))
                    }

                    it("has updateContent effect") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.updateContent(content: "content")))
                    }

                    it("has showError effect") {
                        expect(e.evaluate(event: event).effects[1])
                            .to(equal(.showError(error: "Failed to update note's content", message: "message")))
                    }
                }
            }

            context("when receiving didAddTag event") {
                context("when successfuly adds tag") {
                    beforeEach {
                        event = .didAddTag(result: Result(updatedNote), tag: "added tag")
                    }

                    it("has addTag effect") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.addTag(tag: "added tag")))
                    }

                    it("updates model with updated note") {
                        expect(e.evaluate(event: event).model.note.tags)
                            .to(equal(["added tag"]))
                    }
                }

                context("when fails to add tag") {
                    beforeEach {
                        event = .didAddTag(result: Result(error: error), tag: "added tag")
                    }

                    it("has showTags effect") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.showTags(tags: ["tag"])))
                    }

                    it("has showError effect") {
                        expect(e.evaluate(event: event).effects[1])
                            .to(equal(.showError(error: "Failed to add tag", message: "message")))
                    }
                }
            }

            context("when receiving didRemoveTag event") {
                context("when successfully removes tag") {
                    beforeEach {
                        event = .didRemoveTag(result: Result(updatedNote), tag: "removed tag")
                    }

                    it("has removeTag effect") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.removeTag(tag: "removed tag")))
                    }

                    it("updates model with updated note") {
                        expect(e.evaluate(event: event).model.note.tags)
                            .to(equal(["added tag"]))
                    }
                }

                context("when fails to remove tag") {
                    beforeEach {
                        event = .didRemoveTag(result: Result(error: error), tag: "removed tag")
                    }

                    it("has showTags effect") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.showTags(tags: ["tag"])))
                    }

                    it("has showError effect") {
                        expect(e.evaluate(event: event).effects[1])
                            .to(equal(.showError(error: "Failed to remove tag", message: "message")))
                    }
                }
            }

            context("when receiving didDeleteNote event") {
                context("when successfully deletes note") {
                    beforeEach {
                        event = .didDeleteNote(error: nil)
                    }

                    it("has finish action") {
                        expect(e.evaluate(event: event).actions[0])
                            .to(equal(UI.Note.Action.finish))
                    }
                }

                context("when fails to delete note") {
                    beforeEach {
                        event = .didDeleteNote(error: error)
                    }

                    it("has showError effect") {
                        expect(e.evaluate(event: event).effects[0])
                            .to(equal(.showError(error: "Failed to delete note", message: "message")))
                    }
                }
            }
        }
    }
}
