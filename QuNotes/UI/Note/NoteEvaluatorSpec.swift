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
        }
    }
}
