//
//  NotebookExperimentalSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NotebookExperimantalSpec: QuickSpec {
    override func spec() {
        let model = Experimental.Notebook.Model(uuid: "uuid", name: "name", notes: [])
        var e: Experimental.Notebook.Evaluator!

        beforeEach {
            e = Experimental.Notebook.Evaluator(model: model)
        }

        describe("-evaluate:") {
            var event: Experimental.Notebook.InputEvent!

            context("when receiving changeName event") {
                let expectedModel = Experimental.Notebook.Model(uuid: "uuid", name: "new name", notes: [])

                beforeEach {
                    event = .changeName(newName: "new name")
                }

                it("has updateModel action with new name") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.updateModel(model: expectedModel)))
                }
            }

            context("when receiving addNote event") {
                let noteToAdd = Experimental.Note.Model(uuid: "noteUUID", title: "title", content: "content")

                beforeEach {
                    event = .addNote(note: noteToAdd)
                }

                it("has createFile action with URL of new note") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.createFile(url: URL(string: "uuid.qvnotebook/noteUUID.qvnote")!)))
                }

                it("updates model by adding new note") {
                    expect(e.evaluate(event: event).model.notes[0])
                        .to(equal(noteToAdd))
                }
            }
                }

                it("creates note with uniq uuid") {
                    let model = e.evaluate(event: event).evaluate(event: event).model
                    expect(model.notes[0].uuid).toNot(equal(model.notes[1].uuid))
                }
            }
        }
    }
}
