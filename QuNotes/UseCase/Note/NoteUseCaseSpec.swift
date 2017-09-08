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

        describe("-getAll") {
            context("when repository returns error") {

                beforeEach {
                    noteRepositoryStub.resultToBeReturnedFromGetAllMethod = .failure(AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }

                it("returns empty array") {
                    expect(useCase.getAll()).to(beEmpty())
                }
            }

            context("when repository returns array of notes") {

                var notesFromRepository: [Note]!

                beforeEach() {
                    notesFromRepository = [Note.noteFixture(), Note.noteFixture()]
                    noteRepositoryStub.resultToBeReturnedFromGetAllMethod = .success(notesFromRepository)
                }

                it("returns notes from repository") {
                    expect(useCase.getAll()).to(equal(notesFromRepository))
                }
            }
        }

        describe("-add:") {
            context("when save method succedes") {

                beforeEach {
                    noteRepositoryStub.returnNotePassedInSaveMethod = true
                }

                context("when currentDateService returns timestamp with value 15") {

                    beforeEach {
                        currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 15)
                    }

                    it("returns note with passed title, empty content, correct created and updated dates") {
                        let note = useCase.add(withTitle: "note title").value
                        expect(note?.title).to(equal("note title"))
                        expect(note?.content).to(beEmpty())
                        expect(note?.createdDate).to(beCloseTo(15))
                        expect(note?.updatedDate).to(beCloseTo(15))
                    }

                    it("returns note with uniq uuid") {
                        let firstNote = useCase.add(withTitle: "first note title").value
                        let secondNote = useCase.add(withTitle: "second note title").value
                        expect(firstNote).toNot(beNil())
                        expect(secondNote).toNot(beNil())
                        expect(firstNote?.uuid).toNot(equal(secondNote?.uuid))
                    }
                }
            }

            context("when save method fails") {

                beforeEach {
                    noteRepositoryStub.resultToBeReturnedFromSaveMethod = .failure(AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).toNot(beNil())
                    expect(receivedError).to(equal(.failedToFindDocumentDirectory))
                }
            }
        }

        describe("-update:newContent:") {

            var note: Note!

            beforeEach {
                note = Note.noteFixture()
                currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
            }

            it("calls save method of repository with note with same id, created date, title") {
                _ = useCase.update(note, newContent: "new note fixture");
                expect(noteRepositoryStub.notePassedInSaveMethod?.uuid).to(equal(note.uuid))
                expect(noteRepositoryStub.notePassedInSaveMethod?.createdDate).to(beCloseTo(note.createdDate))
                expect(noteRepositoryStub.notePassedInSaveMethod?.title).to(equal(note.title))
            }

            it("calls save method of repository with note with updated date and content") {
                _ = useCase.update(note, newContent: "new note fixture");
                expect(noteRepositoryStub.notePassedInSaveMethod?.updatedDate).to(beCloseTo(20))
                expect(noteRepositoryStub.notePassedInSaveMethod?.content).to(equal("new note fixture"))
            }

            context("when save method succedes") {

                beforeEach {
                    noteRepositoryStub.returnNotePassedInSaveMethod = true
                }

                it("returns result with updated note") {
                    let result = useCase.update(note, newContent: "new note fixture");
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
                    noteRepositoryStub.resultToBeReturnedFromSaveMethod = .failure(AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).toNot(beNil())
                    expect(receivedError).to(equal(.failedToFindDocumentDirectory))
                }
            }
        }

        describe("-update:newTitle:") {

            var note: Note!

            beforeEach {
                note = Note.noteFixture()
                currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
            }

            it("calls save method of repository with note with same id, created date, content") {
                _ = useCase.update(note, newTitle: "new note title fixture");
                expect(noteRepositoryStub.notePassedInSaveMethod?.uuid).to(equal(note.uuid))
                expect(noteRepositoryStub.notePassedInSaveMethod?.createdDate).to(beCloseTo(note.createdDate))
                expect(noteRepositoryStub.notePassedInSaveMethod?.content).to(equal(note.content))
            }

            it("calls save method of repository with note with updated date and title") {
                _ = useCase.update(note, newTitle: "new note title fixture");
                expect(noteRepositoryStub.notePassedInSaveMethod?.updatedDate).to(beCloseTo(20))
                expect(noteRepositoryStub.notePassedInSaveMethod?.title).to(equal("new note title fixture"))
            }

            context("when save method succedes") {

                beforeEach {
                    noteRepositoryStub.returnNotePassedInSaveMethod = true
                }

                it("returns result with updated note") {
                    let result = useCase.update(note, newTitle: "new note title fixture");
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
                    noteRepositoryStub.resultToBeReturnedFromSaveMethod = .failure(AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).toNot(beNil())
                    expect(receivedError).to(equal(.failedToFindDocumentDirectory))
                }
            }
        }

        describe("-delete") {

            let note = Note.noteFixture()

            it("calls delete method of repository with passed note") {
                _ = useCase.delete(note)
                expect(noteRepositoryStub.notePassedInDeleteMethod).to(equal(note))
            }

            context("when repository failes to delete note") {

                beforeEach() {
                    noteRepositoryStub.resultToBeReturnedFromGetMethod = .failure(AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory))
                }

                it("returns result with error from repository") {
                    let error = useCase.delete(note).error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(.failedToFindDocumentDirectory))
                }
            }

            context("when repository successes to delete note") {

                beforeEach() {
                    noteRepositoryStub.returnNotePassedInDeleteMethod = true
                }

                it("return result with deleted note") {
                    let result = useCase.delete(note)
                    expect(result.value).to(equal(note))
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
    var resultToBeReturnedFromGetAllMethod: Result<[Note], AnyError>?
    var resultToBeReturnedFromGetMethod: Result<Note, AnyError>?
    var resultToBeReturnedFromSaveMethod: Result<Note, AnyError>?
    var returnNotePassedInSaveMethod = false
    var resultToBeReturnedFromDeleteMethod: Result<Note, AnyError>?
    var returnNotePassedInDeleteMethod = false
    private(set) var notePassedInSaveMethod: Note?
    private(set) var notePassedInDeleteMethod: Note?

    func getAll() -> Result<[Note], AnyError> {
        return resultToBeReturnedFromGetAllMethod ?? .failure(AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory))
    }

    func get(noteId: String) -> Result<Note, AnyError> {
        return resultToBeReturnedFromGetMethod ?? defaultFailure()
    }

    func save(note: Note) -> Result<Note, AnyError> {
        notePassedInSaveMethod = note
        let resultToBeReturned = resultToBeReturnedFromSaveMethod ?? defaultFailure()
        return returnNotePassedInSaveMethod ? .success(note) : resultToBeReturned
    }

    func delete(note: Note) -> Result<Note, AnyError> {
        notePassedInDeleteMethod = note
        let resultToBeReturned = resultToBeReturnedFromDeleteMethod ?? defaultFailure()
        return returnNotePassedInDeleteMethod ? .success(note) : resultToBeReturned
    }

    private func defaultFailure() -> Result<Note, AnyError> {
        return .failure(AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory))
    }
}

