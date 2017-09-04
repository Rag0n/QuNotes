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

            var note: Note!

            beforeEach {
                note = Note.noteFixture()
                currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
            }

            it("calls save method of repository with note with same id, created date, content") {
                _ = useCase.updateNote(note, newTitle: "new note title fixture");
                expect(noteRepositoryStub.notePassedInSaveMethod?.uuid).to(equal(note.uuid))
                expect(noteRepositoryStub.notePassedInSaveMethod?.createdDate).to(beCloseTo(note.createdDate))
                expect(noteRepositoryStub.notePassedInSaveMethod?.content).to(equal(note.content))
            }

            it("calls save method of repository with note with updated date and title") {
                _ = useCase.updateNote(note, newTitle: "new note title fixture");
                expect(noteRepositoryStub.notePassedInSaveMethod?.updatedDate).to(beCloseTo(20))
                expect(noteRepositoryStub.notePassedInSaveMethod?.title).to(equal("new note title fixture"))
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
                    expect(updatedNote?.title).to(equal("new note title fixture"))
                    expect(updatedNote?.updatedDate).to(beCloseTo(20))
                    expect(updatedNote?.content).to(equal(note.content))
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

        describe("-deleteNote") {

            let note = Note.noteFixture()

            it("calls delete method of repository with passed note") {
                _ = useCase.deleteNote(note)
                expect(noteRepositoryStub.notePassedInDeleteMethod).to(equal(note))
            }
            
            context("when repository failes to delete note") {

                beforeEach() {
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = .failure(.savingError)
                }

                it("returns result with error from repository") {
                    let result = useCase.deleteNote(note)
                    expect(result.error).to(equal(NoteUseCaseError.savingError))
                }
            }

            context("when repository successes to delete note") {

                beforeEach() {
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = .success(note)
                }

                it("return result with deleted note") {
                    let result = useCase.deleteNote(note)
                    expect(result.value).to(equal(note))
                }
            }
        }

        describe("-addTag:toNote:") {

            var note: Note!

            beforeEach {
                note = Note.noteFixture()
                currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
            }

            it("calls save method of repository with note with same id, created date, content, title") {
                _ = useCase.addTag(tag: "tag fixture", toNote: note)
                expect(noteRepositoryStub.notePassedInSaveMethod?.uuid).to(equal(note.uuid))
                expect(noteRepositoryStub.notePassedInSaveMethod?.createdDate).to(beCloseTo(note.createdDate))
                expect(noteRepositoryStub.notePassedInSaveMethod?.content).to(equal(note.content))
                expect(noteRepositoryStub.notePassedInSaveMethod?.title).to(equal(note.title))
            }

            it("calls save method of repository with note with updated date and tags") {
                _ = useCase.addTag(tag: "tag fixture", toNote: note)
                expect(noteRepositoryStub.notePassedInSaveMethod?.updatedDate).to(beCloseTo(20))
                expect(noteRepositoryStub.notePassedInSaveMethod?.tags).to(equal(["tag fixture"]))
            }

            context("when save method succedes") {

                beforeEach {
                    noteRepositoryStub.returnNotePassedInSaveMethod = true
                }

                context("when note doesnt have any tags") {
                    it("returns result with note with new tag") {
                        let updatedNote = useCase.addTag(tag: "tag fixture", toNote: note).value
                        expect(updatedNote?.uuid).to(equal(note.uuid))
                        expect(updatedNote?.createdDate).to(beCloseTo(note.createdDate))
                        expect(updatedNote?.title).to(equal(note.title))
                        expect(updatedNote?.content).to(equal(note.content))
                        expect(updatedNote?.updatedDate).to(beCloseTo(20))
                        expect(updatedNote?.tags).to(equal(["tag fixture"]))
                    }
                }

                context("when note already has some tags") {

                    beforeEach {
                        note = Note.noteFixtureWithTags(["tag fixture"])
                    }

                    it("returns updated note with appended tag") {
                        let updatedNote = useCase.addTag(tag: "another tag fixture", toNote: note).value
                        expect(updatedNote?.uuid).to(equal(note.uuid))
                        expect(updatedNote?.createdDate).to(beCloseTo(note.createdDate))
                        expect(updatedNote?.title).to(equal(note.title))
                        expect(updatedNote?.content).to(equal(note.content))
                        expect(updatedNote?.updatedDate).to(beCloseTo(20))
                        expect(updatedNote?.tags).to(equal(["tag fixture", "another tag fixture"]))
                    }
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

        describe("-removeTag:fromNote:") {

            var note: Note!

            beforeEach {
                note = Note.noteFixture()
                currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
            }

            context("when save method succedes") {

                beforeEach {
                    noteRepositoryStub.returnNotePassedInSaveMethod = true
                }

                context("when note doesnt have this tag") {
                    it("returns note with without changing updatedDate") {
                        let updatedNote = useCase.removeTag(tag: "tag fixture", fromNote: note).value
                        expect(updatedNote?.uuid).to(equal(note.uuid))
                        expect(updatedNote?.createdDate).to(beCloseTo(note.createdDate))
                        expect(updatedNote?.title).to(equal(note.title))
                        expect(updatedNote?.content).to(equal(note.content))
                        expect(updatedNote?.updatedDate).to(beCloseTo(note.updatedDate))
                        expect(updatedNote?.tags).to(beEmpty())
                    }
                }

                context("when note has this tag") {

                    beforeEach {
                        note = Note.noteFixtureWithTags(["tag fixture", "another tag fixture"])
                    }

                    it("returns note with removed tag and new updatedDate") {
                        let updatedNote = useCase.removeTag(tag: "tag fixture", fromNote: note).value
                        expect(updatedNote?.uuid).to(equal(note.uuid))
                        expect(updatedNote?.createdDate).to(beCloseTo(note.createdDate))
                        expect(updatedNote?.title).to(equal(note.title))
                        expect(updatedNote?.content).to(equal(note.content))
                        expect(updatedNote?.updatedDate).to(beCloseTo(20))
                        expect(updatedNote?.tags).to(equal(["another tag fixture"]))
                    }
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
    var returnNotePassedInSaveMethod = false
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
        notePassedInSaveMethod = note
        return returnNotePassedInSaveMethod ? note : (resultToBeReturnedFromSaveMethod ?? .failure(NoteUseCaseError.savingError))
    }

    func delete(note: Note) -> Result<Note, NoteUseCaseError> {
        notePassedInDeleteMethod = note
        return resultToBeReturnedFromDeleteMethod ?? .failure(NoteUseCaseError.savingError)
    }
}
