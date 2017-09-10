//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

// MARK: - NoteUseCaseSpec

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
                    noteRepositoryStub.saveMethodError = AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory)
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
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

            it("calls save method of repository with note with updated date and content") {
                _ = useCase.update(note, newContent: "new note fixture");
                expect(noteRepositoryStub.notePassedInSaveMethod).to(equal(note: note, withNewUpdatedDate: 20, withNewContent: "new note fixture"))
            }

            context("when save method succedes") {

                beforeEach {
                    noteRepositoryStub.returnNotePassedInSaveMethod = true
                }

                it("returns result with updated note") {
                    let updatedNote = useCase.update(note, newContent: "new note fixture").value
                    expect(updatedNote).to(equal(note: note, withNewUpdatedDate: 20, withNewContent: "new note fixture"))
                }
            }

            context("when save method fails") {

                beforeEach {
                    noteRepositoryStub.saveMethodError = AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory)
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
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

            it("calls save method of repository with note with updated date and title") {
                _ = useCase.update(note, newTitle: "new note title fixture")
                expect(noteRepositoryStub.notePassedInSaveMethod).to(equal(note: note, withNewUpdatedDate: 20, withNewTitle: "new note title fixture"))
            }

            context("when save method succedes") {

                beforeEach {
                    noteRepositoryStub.returnNotePassedInSaveMethod = true
                }

                it("returns result with updated note") {
                    let updatedNote = useCase.update(note, newTitle: "new note title fixture").value
                    expect(updatedNote).to(equal(note: note, withNewUpdatedDate: 20, withNewTitle: "new note title fixture"))
                }
            }

            context("when save method fails") {

                beforeEach {
                    noteRepositoryStub.saveMethodError = AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory)
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
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

        describe("-addTag:toNote:") {

            var note: Note!

            beforeEach {
                note = Note.noteFixture()
                currentDateServiceStub.currentDateStub = Date(timeIntervalSince1970: 20)
            }

            it("calls save method of repository with note with updated date and tags") {
                _ = useCase.addTag(tag: "tag fixture", toNote: note)
                expect(noteRepositoryStub.notePassedInSaveMethod).to(equal(note: note, withNewUpdatedDate: 20, withNewTags: ["tag fixture"]))
            }

            context("when save method succedes") {

                beforeEach {
                    noteRepositoryStub.returnNotePassedInSaveMethod = true
                }

                context("when note doesnt have any tags") {
                    it("returns result with note with new tag") {
                        let updatedNote = useCase.addTag(tag: "tag fixture", toNote: note).value
                        expect(updatedNote).to(equal(note: note, withNewUpdatedDate: 20, withNewTags: ["tag fixture"]))
                    }
                }

                context("when note already has some tags") {

                    beforeEach {
                        note = Note.noteFixtureWithTags(["tag fixture"])
                    }

                    it("returns updated note with appended tag") {
                        let updatedNote = useCase.addTag(tag: "another tag fixture", toNote: note).value
                        expect(updatedNote).to(equal(note: note, withNewUpdatedDate: 20, withNewTags: ["tag fixture", "another tag fixture"]))
                    }
                }
            }

            context("when save method fails") {

                beforeEach {
                    noteRepositoryStub.saveMethodError = AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory)
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(.failedToFindDocumentDirectory))
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
                        expect(updatedNote).to(equal(note: note))
                    }
                }

                context("when note has this tag") {

                    beforeEach {
                        note = Note.noteFixtureWithTags(["tag fixture", "another tag fixture"])
                    }

                    it("returns note with removed tag and new updatedDate") {
                        let updatedNote = useCase.removeTag(tag: "tag fixture", fromNote: note).value
                        expect(updatedNote).to(equal(note: note, withNewUpdatedDate: 20, withNewTags: ["another tag fixture"]))
                    }
                }
            }

            context("when save method fails") {

                beforeEach {
                    noteRepositoryStub.saveMethodError = AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory)
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(.failedToFindDocumentDirectory))
                }
            }
        }
    }
}

// MARK: - CurrentDateServiceFake

class CurrentDateServiceFake: CurrentDateService {
    var currentDateStub: Date

    init() {
        self.currentDateStub = Date(timeIntervalSince1970: 10)
    }

    func currentDate() -> Date {
        return currentDateStub
    }
}

// MARK: - NoteRepositoryFake

class NoteRepositoryFake: NoteRepository {
    var resultToBeReturnedFromGetAllMethod: Result<[Note], AnyError>?
    var resultToBeReturnedFromGetMethod: Result<Note, AnyError>?
    var saveMethodError: AnyError?
    var returnNotePassedInSaveMethod = false
    var deleteMethodEror: AnyError?
    var returnNotePassedInDeleteMethod = false
    private(set) var notePassedInSaveMethod: Note?
    private(set) var notePassedInDeleteMethod: Note?

    func getAll() -> Result<[Note], AnyError> {
        return resultToBeReturnedFromGetAllMethod ?? .failure(defaultError())
    }

    func get(noteId: String) -> Result<Note, AnyError> {
        return resultToBeReturnedFromGetMethod ?? .failure(defaultError())
    }

    func save(note: Note) -> Result<Note, AnyError> {
        notePassedInSaveMethod = note
        return returnNotePassedInSaveMethod ? .success(note) : .failure((saveMethodError ?? defaultError()))
    }

    func delete(note: Note) -> Result<Note, AnyError> {
        notePassedInDeleteMethod = note
        return returnNotePassedInDeleteMethod ? .success(note) : .failure((deleteMethodEror ?? defaultError()))
    }

    private func defaultError() -> AnyError {
        return AnyError(FileNoteRepositoryError.failedToFindDocumentDirectory)
    }
}

// MARK: - Custom matchers

func equal(note expectedNote: Note,
           withNewCreatedDate createdDate: Double? = nil,
           withNewUpdatedDate updatedDate: Double? = nil,
           withNewContent content: String? = nil,
           withNewTitle title: String? = nil,
           withNewUUID uuid: String? = nil,
           withNewTags tags: [String]? = nil) -> Predicate<Note> {
    return Predicate { (actualExpression: Expression<Note>) throws -> PredicateResult in
        var msg = ExpectationMessage.expectedTo("receive equal note with new properties: ")
        guard let note = try actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: msg.appendedBeNilHint()
            )
        }

        var details = ""

        let expectedCreatedDate = createdDate ?? expectedNote.createdDate
        let isCreatedDateEqual = fabs(note.createdDate - expectedCreatedDate) < Double.ulpOfOne
        details = isCreatedDateEqual ? details : details.appending("CreatedDate is not equal. Expected \(expectedCreatedDate), got \(note.createdDate) ")

        let expectedUpdatedDate = updatedDate ?? expectedNote.updatedDate
        let isUpdatedDateEqual = fabs(note.updatedDate - expectedUpdatedDate) < Double.ulpOfOne
        details = isUpdatedDateEqual ? details : details.appending("UpdatedDate is not equal. Expected \(expectedUpdatedDate), got \(note.updatedDate) ")

        let expectedContent = content ?? expectedNote.content
        let isContentEqual = note.content == expectedContent
        details = isContentEqual ? details : details.appending("Content is not equal: expected \(expectedContent), got \(note.content) ")

        let expectedTitle = title ?? expectedNote.title
        let isTitleEqual = note.title == expectedTitle
        details = isTitleEqual ? details : details.appending("Title is not equal: expected \(expectedTitle), got \(note.title) ")

        let expectedUUID = uuid ?? expectedNote.uuid
        let isUUIDEqual = note.uuid == expectedUUID
        details = isUUIDEqual ? details : details.appending("UUID is not equal: expected \(expectedUUID), got \(note.uuid) ")

        let expectedTags = tags ?? expectedNote.tags
        let areTagsEqual = note.tags == expectedTags
        details = areTagsEqual ? details : details.appending("Tags are not equal: expected \(expectedTags), got \(note.tags) ")

        msg = details.isEmpty ? msg : msg.appended(details: details)

        return PredicateResult(
            bool: isUpdatedDateEqual && isCreatedDateEqual && isContentEqual && isTitleEqual && isUUIDEqual && areTagsEqual,
            message: msg
        )
    }
}

