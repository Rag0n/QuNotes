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
            notebook = Notebook()
        }

        describe("-init(name)") {
            it("sets passed name") {
                let notebook = Notebook(name: "name fixture")
                expect(notebook.name).to(equal("name fixture"))
            }

            it("sets uniq uuid") {
                let anotherNotebook = Notebook()
                expect(notebook.uuid).notTo(equal(anotherNotebook.uuid))
            }
        }

        describe("-init") {
            it("sets empty name") {
                expect(notebook.name).to(equal(""))
            }
        }

        describe("-addNote") {
            context("adding 1 note") {
                it("adds new note") {
                    notebook.addNote("note fixture")
                    expect(notebook.allNotes().count).to(equal(1))
                }
            }

            context("adding 2 notes") {
                it("adds two new notes") {
                    notebook.addNote("first note fixture")
                    notebook.addNote("second note fixture")
                    expect(notebook.allNotes().count).to(equal(2))
                }
           }
        }

        describe("-getNote") {
            context("when nothing is added") {
                it("returns error") {
                    let note = notebook.getNote(0)
                    expect(note.error).to(matchError(NotebookError.noteIsNotExists))
                }
            }

            context("when 1 note is added") {

                let addedNote = "note fixture"

                beforeEach {
                    notebook.addNote(addedNote)
                }

                context("when requested first note") {
                    it("returns first note") {
                        let requestedNote = notebook.getNote(0)
                        expect(requestedNote.value).to(equal(addedNote))
                    }
                }

                context("when requested second note") {
                    it("returns error") {
                        let requestedNote = notebook.getNote(1)
                        expect(requestedNote.error).to(matchError(NotebookError.noteIsNotExists))
                    }
                }
            }
        }

        describe("-allNotes") {
            context("when created") {
                it("returns 0") {
                    let notes = notebook.allNotes()
                    expect(notes.count).to(equal(0))
                }
            }

            context("when 1 note is added") {
                it("returns 1") {
                    notebook.addNote("fixtore note")
                    expect(notebook.allNotes().count).to(equal(1))
                }
            }
        }
    }
}
