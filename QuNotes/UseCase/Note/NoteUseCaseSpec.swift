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
            context("when repository returns error") {

                beforeEach {
                    noteRepositoryStub.resultToBeReturnedFromGetAllMethod = .failure(.brokenFormat)
                }

                it("returns empty array") {
                    expect(useCase.getAllNotes()).to(beEmpty())
                }
            }

            context("when repository returns array of notes") {

                var notesFromRepository: [Note]!

                beforeEach() {
                    notesFromRepository = [Note.noteFixture(), Note.noteFixture()]
                    noteRepositoryStub.resultToBeReturnedFromGetAllMethod = .success(notesFromRepository)
                }

                it("returns notes from repository") {
                    expect(useCase.getAllNotes()).to(equal(notesFromRepository))
                }
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

            var note: Note!

            beforeEach {
                note = Note.noteFixture()
                currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
            }

            it("calls save method of repository with note with same id, created date, title") {
                _ = useCase.updateNote(note, newContent: "new note fixture");
                expect(noteRepositoryStub.notePassedInSaveMethod?.uuid).to(equal(note.uuid))
                expect(noteRepositoryStub.notePassedInSaveMethod?.createdDate).to(beCloseTo(note.createdDate))
                expect(noteRepositoryStub.notePassedInSaveMethod?.title).to(equal(note.title))
            }

            it("calls save method of repository with note with updated date and content") {
                _ = useCase.updateNote(note, newContent: "new note fixture");
                expect(noteRepositoryStub.notePassedInSaveMethod?.updatedDate).to(beCloseTo(20))
                expect(noteRepositoryStub.notePassedInSaveMethod?.content).to(equal("new note fixture"))
            }

            context("when save method succedes") {

                beforeEach {
                    noteRepositoryStub.resultToBeReturnedFromSaveMethod = .success(note)
                }

                it("returns result with updated note") {
                    let result = useCase.updateNote(note, newContent: "new note fixture");
                    let updatedNote = result.value
                    expect(updatedNote).toNot(beNil())
                    expect(updatedNote?.uuid).to(equal(note.uuid))
                    expect(updatedNote?.createdDate).to(beCloseTo(note.createdDate))
                    expect(updatedNote?.title).to(equal(note.title))
                    expect(updatedNote?.updatedDate).to(beCloseTo(20))
                    expect(updatedNote?.content).to(equal("new note fixture"))
                }
            }

            context("when save method fails") {

                beforeEach {
                    noteRepositoryStub.resultToBeReturnedFromSaveMethod = .failure(NoteUseCaseError.savingError)
                }

                it("return result with save error") {
                    let result = useCase.updateNote(note, newContent: "new note fixture");
                    let error = result.error
                    expect(error).toNot(beNil())
                    expect(error).to(equal(NoteUseCaseError.savingError))
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

        describe("-removeTag:fromNote:") {
            context("when removing tag from added note") {

                var existingNote: Note!

                beforeEach {
                    existingNote = useCase.addNote(withTitle: "title fixture")
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = Result.success(existingNote)
                    currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
                }

                it("calls save method of repository with note with same id, created date, content, title") {
                    _ = useCase.removeTag(tag: "tag fixture", fromNote: existingNote)
                    expect(noteRepositoryStub.notePassedInSaveMethod?.uuid).to(equal(existingNote.uuid))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.createdDate).to(beCloseTo(existingNote.createdDate))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.content).to(equal(existingNote.content))
                    expect(noteRepositoryStub.notePassedInSaveMethod?.title).to(equal(existingNote.title))
                }

                context("when note doesnt have this tag") {
                    it("returns note with without changing updatedDate") {
                        let updatedNote = useCase.removeTag(tag: "tag fixture", fromNote: existingNote)
                        expect(updatedNote?.uuid).to(equal(existingNote.uuid))
                        expect(updatedNote?.createdDate).to(beCloseTo(existingNote.createdDate))
                        expect(updatedNote?.title).to(equal(existingNote.title))
                        expect(updatedNote?.content).to(equal(existingNote.content))
                        expect(updatedNote?.updatedDate).to(beCloseTo(existingNote.updatedDate))
                        expect(updatedNote?.tags).to(beEmpty())
                    }
                }

                context("when note has this tag") {

                    beforeEach {
                        existingNote = useCase.addTag(tag: "tag fixture", toNote: existingNote)
                        existingNote = useCase.addTag(tag: "another tag fixture", toNote: existingNote)
                    }

                    it("returns note with removed tag and new updatedDate") {
                        let updatedNote = useCase.removeTag(tag: "tag fixture", fromNote: existingNote)
                        expect(updatedNote?.uuid).to(equal(existingNote.uuid))
                        expect(updatedNote?.createdDate).to(beCloseTo(existingNote.createdDate))
                        expect(updatedNote?.title).to(equal(existingNote.title))
                        expect(updatedNote?.content).to(equal(existingNote.content))
                        expect(updatedNote?.updatedDate).to(beCloseTo(20))
                        expect(updatedNote?.tags).to(equal(["another tag fixture"]))
                    }
                }
            }

            context("when removing tag from not added note") {

                let notAddedNote = Note.noteFixtureWithContent("not added note fixture")

                beforeEach {
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = Result.failure(NoteRepositoryError.notFound)
                }

                it("doesnt call save method of repository") {
                    _ = useCase.removeTag(tag: "tag fixture", fromNote: notAddedNote)
                    expect(noteRepositoryStub.notePassedInSaveMethod).to(beNil())
                }

                it("returns passed note") {
                    let updatedNote = useCase.removeTag(tag: "tag fixture", fromNote: notAddedNote)
                    expect(updatedNote).to(equal(notAddedNote))
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
    var resultToBeReturnedFromGetAllMethod: Result<[Note], NoteUseCaseError>?
    var resultToBeReturnedFromGetMethod: Result<Note, NoteUseCaseError>?
    var resultToBeReturnedFromSaveMethod: Result<Note, NoteUseCaseError>?
    var resultToBeReturnedFromDeleteMethod: Result<Note, NoteUseCaseError>?
    private(set) var notePassedInSaveMethod: Note?
    private(set) var notePassedInDeleteMethod: Note?

    func getAll() -> Result<[Note], NoteUseCaseError> {
        return resultToBeReturnedFromGetAllMethod ?? .failure(NoteUseCaseError.brokenFormat)
    }

    func get(noteId: String) -> Result<Note, NoteUseCaseError> {
        return resultToBeReturnedFromGetMethod ?? .failure(NoteUseCaseError.notFound)
    }

    func save(note: Note) -> Result<Note, NoteUseCaseError> {
        notePassedInSaveMethod = note;
        return resultToBeReturnedFromSaveMethod ?? .failure(NoteUseCaseError.savingError)
    }

    func delete(note: Note) -> Result<Note, NoteUseCaseError> {
        notePassedInDeleteMethod = note
        return resultToBeReturnedFromDeleteMethod ?? .failure(NoteUseCaseError.savingError)
    }
}
