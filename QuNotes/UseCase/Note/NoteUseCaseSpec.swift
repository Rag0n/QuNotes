//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NoteUseCaseSpec: QuickSpec {
    override func spec() {

        var useCase: NoteUseCase!
        var currentDateServiceStub: CurrentDateServiceFake!
        var noteRepositoryStub: NoteRepositoryFake!

        beforeEach {
            currentDateServiceStub = CurrentDateServiceFake()
            noteRepositoryStub = NoteRepositoryFake()
            useCase = NoteUseCase(withNoteReposiroty: noteRepositoryStub, currentDateService: currentDateServiceStub)
        }

        describe("-getAllNotes") {

            beforeEach {
                noteRepositoryStub.notesToBeReturnedFromGetAllMethod = [Note.noteFixture(), Note.noteFixture()]
            }

            it("returns notes from getAll method of repository") {
                expect(useCase.getAllNotes()).to(equal(noteRepositoryStub.notesToBeReturnedFromGetAllMethod))
            }
        }

        describe("-addNote") {
            it("returns new note with title 'note title'") {
                let note = useCase.addNote(withTitle: "note title")
                expect(note.title).to(equal("note title"))
            }

            it("calls save method of repository") {
                let addedNote = useCase.addNote(withTitle: "note title")
                expect(noteRepositoryStub.notePassedInSaveMethod).to(equal(addedNote))
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

        describe("-updateNote:newContent:") {
            context("when updating added note") {

                var existingNote: Note!

                beforeEach {
                    existingNote = useCase.addNote(withTitle: "title fixture")
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = Result.success(existingNote)
                    currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
                }

                it("calls save method of repository with note with same id, created date, title") {
                    _ = useCase.updateNote(existingNote, newContent: "new note fixture");
                    expect(noteRepositoryStub.notePassedInSaveMethod?.uuid).to(equal(existingNote.uuid))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.createdDate).to(beCloseTo(existingNote.createdDate))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.title).to(equal(existingNote.title))
                }

                it("calls save method of repository with note with updated date and content") {
                    _ = useCase.updateNote(existingNote, newContent: "new note fixture");
                    expect(noteRepositoryStub.notePassedInSaveMethod?.updatedDate).to(beCloseTo(20))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.content).to(equal("new note fixture"))
                }

                it("returns updated note") {
                    let updatedNote = useCase.updateNote(existingNote, newContent: "new note fixture");
                    expect(updatedNote?.uuid).to(equal(existingNote.uuid))
                    expect(updatedNote?.createdDate).to(beCloseTo(existingNote.createdDate))
                    expect(updatedNote?.title).to(equal(existingNote.title))
                    expect(updatedNote?.updatedDate).to(beCloseTo(20))
                    expect(updatedNote?.content).to(equal("new note fixture"))
                }
            }

            context("when updating not added note") {

                let notAddedNote = Note.noteFixtureWithContent("not added note fixture")
                
                beforeEach {
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = Result.failure(NoteRepositoryError.notFound)
                }

                it("returns nil") {
                    let updatedNote = useCase.updateNote(notAddedNote, newContent: "new note fixture");
                    expect(updatedNote).to(beNil())
                }

                it("doesnt call save method of repository") {
                    _ = useCase.updateNote(notAddedNote, newContent: "new note fixture");
                    expect(noteRepositoryStub.notePassedInSaveMethod).to(beNil())
                }
            }
        }

        describe("-updateNote:newTitle:") {
            context("when updating added note") {

                var existingNote: Note!

                beforeEach {
                    existingNote = useCase.addNote(withTitle: "title fixture")
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = Result.success(existingNote)
                    currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
                }

                it("calls save method of repository with note with same id, created date, content") {
                    _ = useCase.updateNote(existingNote, newTitle: "new note title fixture");
                    expect(noteRepositoryStub.notePassedInSaveMethod?.uuid).to(equal(existingNote.uuid))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.createdDate).to(beCloseTo(existingNote.createdDate))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.content).to(equal(existingNote.content))
                }

                it("calls save method of repository with note with updated date and title") {
                    _ = useCase.updateNote(existingNote, newTitle: "new note title fixture");
                    expect(noteRepositoryStub.notePassedInSaveMethod?.updatedDate).to(beCloseTo(20))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.title).to(equal("new note title fixture"))
                }

                it("returns updated note") {
                    let updatedNote = useCase.updateNote(existingNote, newTitle: "new note title fixture");
                    expect(updatedNote?.uuid).to(equal(existingNote.uuid))
                    expect(updatedNote?.createdDate).to(beCloseTo(existingNote.createdDate))
                    expect(updatedNote?.title).to(equal("new note title fixture"))
                    expect(updatedNote?.updatedDate).to(beCloseTo(20))
                    expect(updatedNote?.content).to(equal(existingNote.content))
                }
            }

            context("when updating not added note") {

                let notAddedNote = Note.noteFixtureWithContent("not added note fixture")

                beforeEach {
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = Result.failure(NoteRepositoryError.notFound)
                }

                it("returns nil") {
                    let updatedNote = useCase.updateNote(notAddedNote, newTitle: "new note title fixture");
                    expect(updatedNote).to(beNil())
                }

                it("doesnt call save method of repository") {
                    _ = useCase.updateNote(notAddedNote, newTitle: "new note title fixture");
                    expect(noteRepositoryStub.notePassedInSaveMethod).to(beNil())
                }
            }
        }

        describe("-deleteNote") {

            let note = Note.noteFixture()

            it("calls delete method of repository with passed note") {
                useCase.deleteNote(note)
                expect(noteRepositoryStub.notePassedInDeleteMethod).to(equal(note))
            }
        }

        describe("-addTag:toNote:") {
            context("when adding tag to added note") {

                var existingNote: Note!

                beforeEach {
                    existingNote = useCase.addNote(withTitle: "title fixture")
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = Result.success(existingNote)
                    currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
                }

                it("calls save method of repository with note with same id, created date, content, title") {
                    _ = useCase.addTag(tag: "tag fixture", toNote: existingNote)
                    expect(noteRepositoryStub.notePassedInSaveMethod?.uuid).to(equal(existingNote.uuid))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.createdDate).to(beCloseTo(existingNote.createdDate))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.content).to(equal(existingNote.content))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.title).to(equal(existingNote.title))
                }

                context("when note doesnt have any tags") {
                    it("returns updated note with new tag") {
                        let updatedNote = useCase.addTag(tag: "tag fixture", toNote: existingNote)
                        expect(updatedNote?.uuid).to(equal(existingNote.uuid))
                        expect(updatedNote?.createdDate).to(beCloseTo(existingNote.createdDate))
                        expect(updatedNote?.title).to(equal(existingNote.title))
                        expect(updatedNote?.content).to(equal(existingNote.content))
                        expect(updatedNote?.updatedDate).to(beCloseTo(20))
                        expect(updatedNote?.tags).to(equal(["tag fixture"]))
                    }
                }

                context("when note already has some tags") {

                    beforeEach {
                        existingNote = useCase.addTag(tag: "tag fixture", toNote: existingNote)
                    }

                    it("returns updated note with appended tag") {
                        let updatedNote = useCase.addTag(tag: "another tag fixture", toNote: existingNote)
                        expect(updatedNote?.uuid).to(equal(existingNote.uuid))
                        expect(updatedNote?.createdDate).to(beCloseTo(existingNote.createdDate))
                        expect(updatedNote?.title).to(equal(existingNote.title))
                        expect(updatedNote?.content).to(equal(existingNote.content))
                        expect(updatedNote?.updatedDate).to(beCloseTo(20))
                        expect(updatedNote?.tags).to(equal(["tag fixture", "another tag fixture"]))
                    }
                }
            }

            context("when adding tag to not added note") {

                let notAddedNote = Note.noteFixtureWithContent("not added note fixture")

                beforeEach {
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = Result.failure(NoteRepositoryError.notFound)
                }

                it("returns nil") {
                    let updatedNote = useCase.addTag(tag: "tag fixture", toNote: notAddedNote)
                    expect(updatedNote).to(beNil())
                }

                it("doesnt call save method of repository") {
                    _ = useCase.addTag(tag: "tag fixture", toNote: notAddedNote)
                    expect(noteRepositoryStub.notePassedInSaveMethod).to(beNil())
                }
            }
        }
    }
}

class CurrentDateServiceFake: CurrentDateService {
    var currentDateStub: Date

    init() {
        self.currentDateStub = Date(timeIntervalSince1970: 10)
    }

    func currentDate() -> Date {
        return currentDateStub
    }
}

class NoteRepositoryFake: NoteRepository {
    var notesToBeReturnedFromGetAllMethod: [Note]?
    var resultToBeReturnedFromGetMethod: Result<Note, NoteRepositoryError>?
    private(set) var notePassedInSaveMethod: Note?
    private(set) var notePassedInDeleteMethod: Note?

    func getAll() -> [Note] {
        return notesToBeReturnedFromGetAllMethod ?? []
    }

    func get(noteId: String) -> Result<Note, NoteRepositoryError> {
        return resultToBeReturnedFromGetMethod ?? Result.failure(NoteRepositoryError.notFound)
    }

    func save(note: Note) {
        notePassedInSaveMethod = note;
    }

    func delete(note: Note) {
        notePassedInDeleteMethod = note
    }
}
