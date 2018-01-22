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
        let model = Dummy.model

        beforeEach {
            e = Note.Evaluator(note: Dummy.note, cells: Dummy.cells, isNew: Dummy.isNew)
        }

        describe("-evaluate:ViewEvent") {
            var event: Note.ViewEvent!

            context("when receiving didLoad event") {
                beforeEach {
                    event = .didLoad
                }

                context("when note is new") {
                    beforeEach {
                        e = Note.Evaluator(note: Dummy.note, cells: Dummy.cells, isNew: true)
                        e = e.evaluate(event: event)
                    }

                    it("has updateTitle, showTags and focusOnTitle effects") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle("title"),
                            .showTags(["tag"]),
                            .focusOnTitle
                        ]))
                    }
                }

                context("when note is not new") {
                    beforeEach {
                        e = Note.Evaluator(note: Dummy.note, cells: Dummy.cells, isNew: false)
                        e = e.evaluate(event: event)
                    }

                    it("has updateTitle and showTags effects") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle("title"),
                            .showTags(["tag"])
                        ]))
                    }
                }
            }

            context("when receiving changeContent event") {
                let expectedCells =  [Core.Note.Cell(type: .text, data: "newContent")]

                beforeEach {
                    event = .changeContent("newContent", index: 0)
                    e = e.evaluate(event: event)
                }

                it("has updateContent effect") {
                    expect(e.effects).to(equalDiff([
                        .updateContent("newContent")
                    ]))
                }

                it("has updateCells action") {
                    expect(e.actions).to(equalDiff([
                        .updateCells(expectedCells)
                    ]))
                }

                context("when model has cell with that index") {
                    it("updates model by replacing cell") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, cells: expectedCells)
                        ))
                    }
                }

                context("when model doesnt hove cell with that index") {
                    beforeEach {
                        e = Note.Evaluator(note: Dummy.note, cells: [], isNew: Dummy.isNew)
                        e = e.evaluate(event: event)
                    }

                    it("updates model by creating new cell") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, cells: expectedCells)
                        ))
                    }
                }
            }

            context("when receiving changeTitle event") {
                beforeEach {
                    event = .changeTitle("newTitle")
                    e = e.evaluate(event: event)
                }

                it("has updateTitle action") {
                    expect(e.actions).to(equalDiff([
                        .updateTitle("newTitle")
                    ]))
                }

                it("has updateTitle effect") {
                    expect(e.effects).to(equalDiff([
                        .updateTitle("newTitle")
                    ]))
                }

                it("updates title in model") {
                    expect(e.model).to(equalDiff(
                        Dummy.model(fromModel: model, title: "newTitle")
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
                    event = .addTag("new tag")
                    e = e.evaluate(event: event)
                }

                it("has addTag action") {
                    expect(e.actions).to(equalDiff([
                        .addTag("new tag")
                    ]))
                }

                it("has addTag effect") {
                    expect(e.effects).to(equalDiff([
                        .addTag("new tag")
                    ]))
                }

                it("adds tag to model") {
                    expect(e.model).to(equalDiff(
                        Dummy.model(fromModel: model, tags: ["tag", "new tag"])
                    ))
                }
            }

            context("when receiving removeTag event") {
                beforeEach {
                    event = .removeTag("tag")
                    e = e.evaluate(event: event)
                }

                it("has removeTag action") {
                    expect(e.actions).to(equalDiff([
                        .removeTag("tag")
                    ]))
                }

                it("has removeTag effect") {
                    expect(e.effects).to(equalDiff([
                        .removeTag("tag")
                    ]))
                }

                it("removes tag from model") {
                    expect(e.model).to(equalDiff(
                        Dummy.model(fromModel: model, tags: [])
                    ))
                }
            }
        }

        describe("-evaluate:CoordinatorEvent") {
            var event: Note.CoordinatorEvent!

            context("when receiving didLoadContent event") {
                let content = Dummy.content(withData: "loaded content")

                beforeEach {
                    event = .didLoadContent(content)
                    e = e.evaluate(event: event)
                }

                it("updates model with new cells") {
                    expect(e.model).to(equalDiff(
                        Dummy.model(fromModel: model, cells: content.cells)
                    ))
                }

                it("has updateContent effect") {
                    expect(e.effects).to(equalDiff([
                        .updateContent("loaded content")
                    ]))
                }
            }

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
                        event = .didDeleteNote(error: Dummy.error)
                        e = e.evaluate(event: event)
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.deleteNote, reason: Dummy.errorMessage)
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
                        event = .didUpdateTitle(oldTitle: "old title", error: Dummy.error)
                        e = e.evaluate(event: event)
                    }

                    it("updates model with old title") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, title: "old title")
                        ))
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.updateTitle, reason: Dummy.errorMessage)
                        ]))
                    }

                    it("has updateTitle effect") {
                        expect(e.effects).to(equalDiff([
                            .updateTitle("old title")
                        ]))
                    }
                }
            }

            context("when receiving didUpdateCells event") {
                let oldCells = [Core.Note.Cell(type: .text, data: "old content")]

                context("when successfully updates cells") {
                    beforeEach {
                        event = .didUpdateCells(oldCells: oldCells, error: nil)
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

                context("when fails to update cells") {
                    beforeEach {
                        event = .didUpdateCells(oldCells: oldCells, error: Dummy.error)
                        e = e.evaluate(event: event)
                    }

                    it("updates model with old content") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, cells: oldCells)
                        ))
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.updateContent, reason: Dummy.errorMessage)
                        ]))
                    }

                    it("has updateContent effect") {
                        expect(e.effects).to(equalDiff([
                            .updateContent("old content")
                        ]))
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

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("doesnt have actions") {
                        expect(e.actions).to(beEmpty())
                    }
                }

                context("when fails to add tag") {
                    beforeEach {
                        event = .didAddTag("tag", error: Dummy.error)
                        e = e.evaluate(event: event)
                    }

                    it("removes tag from model") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, tags: [])
                        ))
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.addTag, reason: Dummy.errorMessage)
                        ]))
                    }

                    it("has removeTag effect") {
                        expect(e.effects).to(equalDiff([
                            .removeTag("tag")
                        ]))
                    }
                }
            }

            context("when receiving didRemoveTag event") {
                context("when successfully removes tag") {
                    beforeEach {
                        event = .didRemoveTag("removed tag", error: nil)
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
                        event = .didRemoveTag("removed tag", error: Dummy.error)
                        e = e.evaluate(event: event)
                    }

                    it("adds tag back to model") {
                        expect(e.model).to(equalDiff(
                            Dummy.model(fromModel: model, tags: ["tag", "removed tag"])
                        ))
                    }

                    it("has showFailure action") {
                        expect(e.actions).to(equalDiff([
                            .showFailure(.removeTag, reason: Dummy.errorMessage)
                        ]))
                    }

                    it("has addTag effect") {
                        expect(e.effects).to(equalDiff([
                            .addTag("removed tag")
                        ]))
                    }
                }
            }
        }
    }
}

private enum Dummy {
    static let note = Core.Note.Meta(uuid: "uuid", title: "title", tags: ["tag"], updated_at: 14, created_at: 14)
    static let model = Note.Model(title: note.title, tags: note.tags, cells: cells, isNew: false)
    static let cells = [Core.Note.Cell(type: .text, data: "content")]
    static let error = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
    static let errorMessage = "message"
    static var isNew: Bool {
        return model.isNew
    }

    static func model(fromModel model: Note.Model, title: String? = nil,
                      tags: [String]? = nil, cells: [Core.Note.Cell]? = nil, isNew: Bool? = nil) -> Note.Model {
        return Note.Model(title: title ?? model.title,
                          tags: tags ?? model.tags,
                          cells: cells ?? model.cells,
                          isNew: isNew ?? model.isNew)
    }

    static func content(withData data: String) -> Core.Note.Content {
        let cells = [Core.Note.Cell(type: .text, data: data)]
        return Core.Note.Content(title: note.title, cells: cells)
    }
}
