//
//  NotebookSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 09.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NotebookSpec: QuickSpec {
    override func spec() {
        var notebook: Notebook!

        beforeEach {
            notebook = Notebook(uuid: "uuid", name: "name")
        }

        context("when comparing instances with not equal uuid") {
            it("returns false") {
                let anotherNotebook = Notebook(uuid: "another uuid", name: "name")
                expect(notebook == anotherNotebook).to(beFalse())
            }
        }

        context("when comparing instances with equal uuid") {
            it("return true") {
                let anotherNotebook = Notebook(uuid: "uuid", name: "another name")
                expect(notebook == anotherNotebook).to(beTrue())
            }
        }
    }
}

extension Notebook {
    static func notebookDummy(withUUID uuid: String, name: String) -> Notebook {
        return Notebook(uuid: uuid, name: name)
    }

    static func notebookDummy(withUUID uuid: String) -> Notebook {
        return Notebook.notebookDummy(withUUID: uuid, name: "dummy notebook name")
    }

    static func notebookDummy() -> Notebook {
        return Notebook.notebookDummy(withUUID: UUID.init().uuidString, name: "dummy notebook name")
    }
}
