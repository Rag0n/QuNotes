//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble

class NoteUseCaseSpec: QuickSpec {
    override func spec() {

        var useCase: NoteUseCase!
        var currentDateServiceStub: CurrentDateServiceStub!

        beforeEach {
            currentDateServiceStub = CurrentDateServiceStub(currentDateStub: Date(timeIntervalSince1970: 10))
            useCase = NoteUseCase(withNoteReposiroty: InMemoryNoteRepository(), currentDateService: currentDateServiceStub)
        }

        describe("-getAllNotes") {
            context("initially") {
                it("returns empty array") {
                    expect(useCase.getAllNotes()).to(beEmpty())
                }
            }
        }

        describe("-addNote") {
            it("returns new note with title 'note title'") {
                let note = useCase.addNote(withTitle: "note title")
                expect(note.title).to(equal("note title"))
            }

            it("adds note to all notes") {
                _ = useCase.addNote(withTitle: "note title")
                let allNotes = useCase.getAllNotes()
                expect(allNotes.first?.title).to(equal("note title"))
            }

            it("returns note with uniq uuid") {
                let firstNote = useCase.addNote(withTitle: "first note title")
                let secondNote = useCase.addNote(withTitle: "second note title")
                expect(firstNote.uuid).toNot(equal(secondNote.uuid))
            }

            it("returns note with empty content") {
                let note = useCase.addNote(withTitle: "note title")
                expect(note.content).to(beEmpty())
            }

            context("when currentDateService returns timestamp with value 15") {

                beforeEach {
                    currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 15)
                }

                it("returns note with createdDate and updatedDate equal to 15") {
                    let note = useCase.addNote(withTitle: "note title")
                    expect(note.createdDate).to(beCloseTo(15))
                    expect(note.updatedDate).to(beCloseTo(15))
                }
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
                        _ = useCase.updateNote(existingNote, newContent: "new note fixture");
                        let allNotesContent = useCase.getAllNotes().map { note in note.content }
                        expect(allNotesContent).to(contain("second note fixture"))
                        expect(allNotesContent).to(contain("third note fixture"))
                        expect(allNotesContent).to(contain("new note fixture"))
                    }
                }
            }

            context("when updating not added note") {

                let notAddedNote = Note.noteFixtureWithContent("not added note fixture")

                it("returns nil") {
                    let updatedNote = useCase.updateNote(notAddedNote, newContent: "new note fixture");
                    expect(updatedNote).to(beNil())
                }

                it("doesnt add updated note") {
                    _ = useCase.updateNote(notAddedNote, newContent: "new note fixture");
                    let allNotes = useCase.getAllNotes()
                    expect(allNotes).to(beEmpty())
                }
            }
        }
    }
}

class CurrentDateServiceStub: CurrentDateService {
    var currentDateStub: Date

    init(currentDateStub: Date) {
        self.currentDateStub = currentDateStub
    }

    func currentDate() -> Date {
        return currentDateStub
    }
}
