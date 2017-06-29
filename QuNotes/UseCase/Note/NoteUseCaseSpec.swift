//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble

class NoteUseCaseSpec: QuickSpec {
    override func spec() {

        var useCase: NoteUseCase!

        beforeEach {
            useCase = NoteUseCase()
        }

        describe("-getAllNotes") {
            context("initially") {
                it("returns empty array") {
                    expect(useCase.getAllNotes()).to(beEmpty())
                }
            }
        }

        describe("-addNote") {
            it("creates new note") {
                useCase.addNote(withContent: "note fixture")
                let allNotes = useCase.getAllNotes()
                expect(allNotes.first?.content).to(equal("note fixture"))
            }

            it("returns created note") {
                let createdNote = useCase.addNote(withContent: "note fixture");
                expect(createdNote.content).to(equal("note fixture"))
            }
        }

        describe("-updateNote:") {

            context("when updating added note") {

                var existingNote: Note!

                beforeEach {
                    existingNote = useCase.addNote(withContent: "note fixture")
                }

                it("adds updated note to all notes") {
                    let updatedNote = useCase.updateNote(existingNote, newContent: "new note fixture");
                    let allNotes = useCase.getAllNotes()
                    expect(allNotes.first).to(equal(updatedNote))
                }

                it("removes old note from all notes") {
                    let updatedNote = useCase.updateNote(existingNote, newContent: "new note fixture");
                    let allNotes = useCase.getAllNotes()
                    expect(allNotes.count).to(equal(1))
                }

                it("returns note with new content") {
                    let updatedNote = useCase.updateNote(existingNote, newContent: "new note fixture");
                    expect(updatedNote?.content).to(equal("new note fixture"))
                }

                context("when multiple notes are added") {

                    beforeEach {
                        _ = useCase.addNote(withContent: "second note fixture")
                        _ = useCase.addNote(withContent: "third note fixture")
                    }

                    it("doesnt change other notes") {
                        let updatedNote = useCase.updateNote(existingNote, newContent: "new note fixture");
                        let allNotesContent = useCase.getAllNotes().map { note in note.content }
                        expect(allNotesContent).to(contain("second note fixture"))
                        expect(allNotesContent).to(contain("third note fixture"))
                        expect(allNotesContent).to(contain("new note fixture"))
                    }
                }
            }

            context("when updating not added note") {

                let notAddedNote = Note(content: "note added content")

                it("returns nil") {
                    let updatedNote = useCase.updateNote(notAddedNote, newContent: "new note fixture");
                    expect(updatedNote).to(beNil())
                }

                it("doesnt add updated note") {
                    let updatedNote = useCase.updateNote(notAddedNote, newContent: "new note fixture");
                    let allNotes = useCase.getAllNotes()
                    expect(allNotes).to(beEmpty())
                }
            }
        }
    }
}
