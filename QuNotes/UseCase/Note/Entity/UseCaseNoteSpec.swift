//
// Created by Alexander Guschin on 11.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NoteSpec: QuickSpec {
    override func spec() {
        var note: UseCase.Note!

        beforeEach {
            note = UseCase.Note(createdDate: 5, updatedDate: 5, content: "context fixture", title: "title fixture", uuid: "uuid fixture", tags: ["tag fixture"])
        }

        context("when comparing instances with not equal uuid") {
            it("returns false") {
                let anotherNote = UseCase.Note(createdDate: note.createdDate, updatedDate: note.updatedDate, content: note.content, title: note.title, uuid: "another uuid fixture", tags: ["tag fixture"])
                expect(note == anotherNote).to(beFalse())
            }
        }

        context("when comparing instances with equal uuid") {
            it("return true") {
                let anotherNote = UseCase.Note(createdDate: 6, updatedDate: 6, content: "another context fixture", title: "another title fixture", uuid: "uuid fixture", tags: ["another tag fixture"])
                expect(note == anotherNote).to(beTrue())
            }
        }
    }
}

extension UseCase.Note {
    static func noteDummy(withUUID uuid: String, tags: [String]) -> UseCase.Note {
        return UseCase.Note(createdDate: 0, updatedDate: 0, content: "content", title: "title", uuid: uuid, tags: tags)
    }

    static func noteDummy(withUUID uuid: String) -> UseCase.Note {
        return UseCase.Note.noteDummy(withUUID: uuid, tags: [])
    }

    static func noteDummyWithTags(_ tags: [String]) -> UseCase.Note {
        return UseCase.Note.noteDummy(withUUID: UUID.init().uuidString, tags: tags)
    }

    static func noteDummy() -> UseCase.Note {
        return UseCase.Note.noteDummy(withUUID: UUID.init().uuidString, tags: [])
    }

    static func noteDummy(withTitle title: String) -> UseCase.Note {
        return UseCase.Note(createdDate: 0, updatedDate: 0, content: "content", title: title, uuid: UUID.init().uuidString, tags: [])
    }
}
