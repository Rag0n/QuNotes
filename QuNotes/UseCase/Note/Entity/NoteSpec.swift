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
            note = Note(content: "content fixture")
        }

        it("sets created date") {
            expect(note.createdDate).toNot(beNil())
        }

        it("sets passed content") {
            expect(note.content).to(equal("content fixture"))
        }

        context("when comparing two different instances of equal content") {
            it("returns false") {
                let anotherNote = Note(content: note.content)
                expect(note == anotherNote).to(beFalse())
            }
        }

        context("when comparing same instance") {
            it("return true") {
                expect(note == note).to(beTrue())
            }
        }
    }
}

