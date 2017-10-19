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
        var e: UI.Note.Evaluator!
        let note = Note(createdDate: 1, updatedDate: 2, content: "content", title: "title", uuid: "uuid", tags: ["tag"])

        beforeEach {
            e = UI.Note.Evaluator(withNote: note)
        }
        let underlyingError = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "localized message"])
        let error = AnyError(underlyingError)

        describe("-evaluate:ViewControllerEvent:") {
            var event: UI.Note.ViewControllerEvent!

            context("when receiving didLoad event") {
                beforeEach {
                    event = .didLoad
                }

                it("contains updateTitle effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.updateTitle(title: "title")))
                }

                it("contains updateContent effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.updateContent(content: "content")))
                }

                it("contains showTags effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.showTags(tags: ["tag"])))
                }

                it("doesnt contain any actions") {
                    expect(e.evaluate(event: event).actions).to(beEmpty())
                }
            }

            context("when receiving changeContent event") {
                beforeEach {
                    event = .changeContent(newContent: "newContent")
                }

                it("contains updateContent action") {
                    expect(e.evaluate(event: event).actions).to(contain(.updateContent(content: "newContent")))
                }

                it("doesnt contain any effects") {
                    expect(e.evaluate(event: event).updates).to(beEmpty())
                }
            }

            context("when receiving changeTitle event") {
                beforeEach {
                    event = .changeTitle(newTitle: "newTitle")
                }

                it("contains updateTitle action") {
                    expect(e.evaluate(event: event).actions).to(contain(.updateTitle(title: "newTitle")))
                }

                it("doesnt contain any effects") {
                    expect(e.evaluate(event: event).updates).to(beEmpty())
                }
            }

            context("when receiving delete event") {
                beforeEach {
                    event = .delete
                }

                it("contains delete action") {
                    expect(e.evaluate(event: event).actions).to(contain(.deleteNote))
                }

                it("doesnt contain any effects") {
                    expect(e.evaluate(event: event).updates).to(beEmpty())
                }
            }

            context("when receiving addTag event") {
                beforeEach {
                    event = .addTag(tag: "new tag")
                }

                it("contains addTag action") {
                    expect(e.evaluate(event: event).actions).to(contain(.addTag(tag: "new tag")))
                }

                it("doesnt contain any effects") {
                    expect(e.evaluate(event: event).updates).to(beEmpty())
                }
            }

            context("when receiving removeTag event") {
                beforeEach {
                    event = .removeTag(tag: "tag")
                }

                it("contains removeTag action") {
                    expect(e.evaluate(event: event).actions).to(contain(.removeTag(tag: "tag")))
                }

                it("doesnt contain any effects") {
                    expect(e.evaluate(event: event).updates).to(beEmpty())
                }
            }
        }

        describe("-evaluate:CoordinatorEvent:") {
            var event: UI.Note.CoordinatorEvent!
            let updatedNote = Note(createdDate: 2, updatedDate: 3, content: "new content", title: "new title", uuid: "uuid", tags: ["added tag"])

            context("when receiving didUpdateTitle event") {
                beforeEach {
                    event = .didUpdateTitle(note: updatedNote)
                }

                it("contains updateTitle effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.updateTitle(title: "new title")))
                }

                it("updates model with updated note") {
                    expect(e.evaluate(event: event).model.note.title).to(equal("new title"))
                }
            }

            context("when receiving didUpdateContent event") {
                beforeEach {
                    event = .didUpdateContent(note: updatedNote)
                }

                it("contains updateContent effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.updateContent(content: "new content")))
                }

                it("updates model with updated note") {
                    expect(e.evaluate(event: event).model.note.content).to(equal("new content"))
                }
            }

            context("when receiving didAddTag event") {
                beforeEach {
                    event = .didAddTag(note: updatedNote, tag: "added tag")
                }

                it("contains addTag effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.addTag(tag: "added tag")))
                }

                it("updates model with updated note") {
                    expect(e.evaluate(event: event).model.note.tags).to(equal(["added tag"]))
                }
            }

            context("when receiving didRemoveTag event") {
                beforeEach {
                    event = .didRemoveTag(note: updatedNote, tag: "removed tag")
                }

                it("contains removeTag effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.removeTag(tag: "removed tag")))
                }

                it("updates model with updated note") {
                    expect(e.evaluate(event: event).model.note.tags).to(equal(["added tag"]))
                }
            }

            context("when receiving didDeleteNote event") {
                beforeEach {
                    event = .didDeleteNote
                }

                it("contains finish action") {
                    expect(e.evaluate(event: event).actions).to(contain(.finish))
                }
            }

            context("when receiving didFailToUpdateTitle event") {
                beforeEach {
                    event = .didFailToUpdateTitle(error: error)
                }

                it("contains updateTitle effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.updateTitle(title: "title")))
                }

                it("contains showError effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.showError(error: "Failed to update note's title", message: "localized message")))
                }
            }

            context("when receiving didFailToUpdateContent event") {
                beforeEach {
                    event = .didFailToUpdateContent(error: error)
                }

                it("contains updateContent effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.updateContent(content: "content")))
                }

                it("contains showError effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.showError(error: "Failed to update note's content", message: "localized message")))
                }
            }

            context("when receiving didFailToAddTag event") {
                beforeEach {
                    event = .didFailToAddTag(error: error)
                }

                it("contains showTags effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.showTags(tags: ["tag"])))
                }

                it("contains showError effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.showError(error: "Failed to add tag", message: "localized message")))
                }
            }

            context("when receiving didFailToRemoveTag event") {
                beforeEach {
                    event = .didFailToRemoveTag(error: error)
                }

                it("contains showTags effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.showTags(tags: ["tag"])))
                }

                it("contains showError effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.showError(error: "Failed to remove tag", message: "localized message")))
                }
            }

            context("when receiving didFailToDeleteNote event") {
                beforeEach {
                    event = .didFailToDeleteNote(error: error)
                }

                it("contains showError effect") {
                    expect(e.evaluate(event: event).updates).to(contain(.showError(error: "Failed to delete note", message: "localized message")))
                }
            }
        }
    }
}
