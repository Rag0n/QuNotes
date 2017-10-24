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
        let underlyingError = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "localized message"])
        let error = AnyError(underlyingError)

        describe("-evaluate:ViewControllerEvent:") {
            var event: UI.Note.ViewControllerEvent!

            context("when receiving didLoad event") {
                beforeEach {
                    event = .didLoad
                }

                it("contains updateTitle effect") {
                    expect(e.evaluate(event: event).effects).to(contain(.updateTitle(title: "title")))
                }

                it("contains updateContent effect") {
                    expect(e.evaluate(event: event).effects).to(contain(.updateContent(content: "content")))
                }

                it("contains showTags effect") {
                    expect(e.evaluate(event: event).effects).to(contain(.showTags(tags: ["tag"])))
                }
            }

            context("when receiving changeContent event") {
                beforeEach {
                    event = .changeContent(newContent: "newContent")
                }

                it("contains updateContent action") {
                    expect(e.evaluate(event: event).actions).to(contain(.updateContent(content: "newContent")))
                }
            }

            context("when receiving changeTitle event") {
                beforeEach {
                    event = .changeTitle(newTitle: "newTitle")
                }

                it("contains updateTitle action") {
                    expect(e.evaluate(event: event).actions).to(contain(.updateTitle(title: "newTitle")))
                }
            }

            context("when receiving delete event") {
                beforeEach {
                    event = .delete
                }

                it("contains delete action") {
                    expect(e.evaluate(event: event).actions).to(contain(.deleteNote))
                }
            }

            context("when receiving addTag event") {
                beforeEach {
                    event = .addTag(tag: "new tag")
                }

                it("contains addTag action") {
                    expect(e.evaluate(event: event).actions).to(contain(.addTag(tag: "new tag")))
                }
            }

            context("when receiving removeTag event") {
                beforeEach {
                    event = .removeTag(tag: "tag")
                }

                it("contains removeTag action") {
                    expect(e.evaluate(event: event).actions).to(contain(.removeTag(tag: "tag")))
                }
            }
        }

        describe("-evaluate:CoordinatorEvent:") {
            var event: UI.Note.CoordinatorEvent!
            let updatedNote = Note(createdDate: 2, updatedDate: 3, content: "new content", title: "new title", uuid: "uuid", tags: ["added tag"])

            context("when receiving didUpdateTitle event") {
                context("when result is note") {
                    beforeEach {
                        event = .didUpdateTitle(result: Result(updatedNote))
                    }

                    it("contains updateTitle effect") {
                        expect(e.evaluate(event: event).effects).to(contain(.updateTitle(title: "new title")))
                    }

                    it("updates model with updated note") {
                        expect(e.evaluate(event: event).model.note.title).to(equal("new title"))
                    }
                }

                context("when result is error") {
                    beforeEach {
                        event = .didUpdateTitle(result: Result(error: error))
                    }

                    it("contains updateTitle effect") {
                        expect(e.evaluate(event: event).effects).to(contain(.updateTitle(title: "title")))
                    }

                    it("contains showError effect") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.showError(error: "Failed to update note's title", message: "localized message")))
                    }
                }
            }

            context("when receiving didUpdateContent event") {
                context("when result is note") {
                    beforeEach {
                        event = .didUpdateContent(result: Result(updatedNote))
                    }

                    it("contains updateContent effect") {
                        expect(e.evaluate(event: event).effects).to(contain(.updateContent(content: "new content")))
                    }

                    it("updates model with updated note") {
                        expect(e.evaluate(event: event).model.note.content).to(equal("new content"))
                    }
                }

                context("when result is error") {
                    beforeEach {
                        event = .didUpdateContent(result: Result(error: error))
                    }

                    it("contains updateContent effect") {
                        expect(e.evaluate(event: event).effects).to(contain(.updateContent(content: "content")))
                    }

                    it("contains showError effect") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.showError(error: "Failed to update note's content", message: "localized message")))
                    }
                }
            }

            context("when receiving didAddTag event") {
                context("when result is note") {
                    beforeEach {
                        event = .didAddTag(result: Result(updatedNote), tag: "added tag")
                    }

                    it("contains addTag effect") {
                        expect(e.evaluate(event: event).effects).to(contain(.addTag(tag: "added tag")))
                    }

                    it("updates model with updated note") {
                        expect(e.evaluate(event: event).model.note.tags).to(equal(["added tag"]))
                    }
                }

                context("when result is error") {
                    beforeEach {
                        event = .didAddTag(result: Result(error: error), tag: "added tag")
                    }

                    it("contains showTags effect") {
                        expect(e.evaluate(event: event).effects).to(contain(.showTags(tags: ["tag"])))
                    }

                    it("contains showError effect") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.showError(error: "Failed to add tag", message: "localized message")))
                    }
                }
            }

            context("when receiving didRemoveTag event") {
                context("when result is note") {
                    beforeEach {
                        event = .didRemoveTag(result: Result(updatedNote), tag: "removed tag")
                    }

                    it("contains removeTag effect") {
                        expect(e.evaluate(event: event).effects).to(contain(.removeTag(tag: "removed tag")))
                    }

                    it("updates model with updated note") {
                        expect(e.evaluate(event: event).model.note.tags).to(equal(["added tag"]))
                    }
                }

                context("when result is error") {
                    beforeEach {
                        event = .didRemoveTag(result: Result(error: error), tag: "removed tag")
                    }

                    it("contains showTags effect") {
                        expect(e.evaluate(event: event).effects).to(contain(.showTags(tags: ["tag"])))
                    }

                    it("contains showError effect") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.showError(error: "Failed to remove tag", message: "localized message")))
                    }
                }
            }

            context("when receiving didDeleteNote event") {
                context("when error is nil") {
                    beforeEach {
                        event = .didDeleteNote(error: nil)
                    }

                    it("contains finish action") {
                        expect(e.evaluate(event: event).actions).to(contain(.finish))
                    }
                }

                context("when error is not nil") {
                    beforeEach {
                        event = .didDeleteNote(error: error)
                    }

                    it("contains showError effect") {
                        expect(e.evaluate(event: event).effects)
                            .to(contain(.showError(error: "Failed to delete note", message: "localized message")))
                    }
                }
            }
        }
    }
}
