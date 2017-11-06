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
        let model = Experimental.Note.Model(uuid: "uuid", title: "title", content: "content")
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

            context("when receiving changeName event") {
                beforeEach {
                    event = .changeTitle(newTitle: "new title")
                }

                it("updates model by changing note title") {
                    expect(e.evaluate(event: event).model.title)
                        .to(equal("new title"))
                }

                context("when note is added to notebook") {
                    let notebookModel = Experimental.Notebook.Model(uuid: "notebookUUID", name: "name", notes: [])
                    let model = Experimental.Note.Model(uuid: "uuid", title: "title",
                                                                content: "content", notebook: notebookModel)
                    let expectedMeta = Experimental.Note.Meta(uuid: "uuid", title: "new title")
                    let expectedURL = URL(string: "notebookUUID.qvnotebook/uuid.qvnote/meta.json")!

                    beforeEach {
                        e = Experimental.Note.Evaluator(model: model)
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

                context("when note is added to notebook") {
                    let notebookModel = Experimental.Notebook.Model(uuid: "notebookUUID", name: "name", notes: [])
                    let model = Experimental.Note.Model(uuid: "uuid", title: "title",
                                                        content: "content", notebook: notebookModel)
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
        }
    }
}
