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
            note = Note(createdDate: 5, updatedDate: 5, content: "context fixture", title: "title fixture", uuid: "uuid fixture")
        }

        context("when comparing instances with not equal uuid") {
            it("returns false") {
                let anotherNote = Note(createdDate: note.createdDate, updatedDate: note.updatedDate, content: note.content, title: note.title, uuid: "another uuid fixture")
                expect(note == anotherNote).to(beFalse())
            }
        }

        context("when comparing instances with equal uuid") {
            it("return true") {
                let anotherNote = Note(createdDate: 6, updatedDate: 6, content: "another context fixture", title: "another title fixture", uuid: "uuid fixture")
                expect(note == anotherNote).to(beTrue())
            }
        }
    }
}

