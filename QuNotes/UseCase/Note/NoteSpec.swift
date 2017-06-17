//
// Created by Alexander Guschin on 11.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NoteSpec: QuickSpec {
    override func spec() {

        var note: Note!

        beforeEach {
            note = Note()
        }

        describe("-init") {
            it("sets created date") {
                expect(note.createdDate).toNot(beNil())
            }

            it("sets updated date equal to createdDate") {
                expect(note.updatedDate).to(beCloseTo(note.createdDate))
            }
        }

        describe("-allTags") {
            it("returns empty array") {
                expect(note.allTags()).to(beEmpty())
            }

            context("when some tags are inserted") {

                beforeEach {
                    note.addTag("first tag fixture")
                    note.addTag("second tag fixture")
                }

                it("returns array of inserted tags") {
                    let insertedTags = note.allTags()
                    expect(insertedTags).to(contain(["first tag fixture", "second tag fixture"]))
                }
            }
        }

        describe("-addTag") {
            context("with existing tag") {

                let existingTag = "existing tag"

                beforeEach {
                    note.addTag(existingTag)
                }

                it("does nothing") {
                    note.addTag(existingTag)
                    expect(note.allTags()).to(contain(existingTag))
                }

                it("does not update updatedDate") {

                }
            }

            context("with new tag") {
                it("adds new tag") {
                    note.addTag("tag fixture")
                    expect(note.allTags()).to(contain("tag fixture"))
                }

                it("updates updatedDate") {

                }
            }
        }
    }
}

