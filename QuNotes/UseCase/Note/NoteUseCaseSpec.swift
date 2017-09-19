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
        var currentDateServiceStub: CurrentDateServiceStub!

        beforeEach {
            currentDateServiceStub = CurrentDateServiceStub()
            useCase = NoteUseCase()
            useCase.currentDateService = currentDateServiceStub
        }

        describe("-getAll") {
            context("when repository returns error") {
                beforeEach {
                    useCase.repository = FailingToGetNoteRepositoryStub()
                }

                it("returns empty array") {
                    expect(useCase.getAll()).to(beEmpty())
                }
            }

            context("when repository returns array of notes") {
                beforeEach() {
                    useCase.repository = ReturningArrayOfNotesNoteRepositoryStub()
                }

                it("returns notes from repository") {
                    expect(useCase.getAll()).to(equal(ReturningArrayOfNotesNoteRepositoryStub.notes))
                }
            }
        }

        describe("-add:") {
            context("when save method succedes") {
                beforeEach {
                    useCase.repository = SuccessfullySavingNoteRepositorySpy()
                }

                context("when currentDateService returns timestamp with value 20") {
                    it("returns note with passed title, empty content, correct created and updated dates") {
                        let note = useCase.add(withTitle: "note title").value
                        expect(note?.title).to(equal("note title"))
                        expect(note?.content).to(beEmpty())
                        expect(note?.createdDate).to(beCloseTo(currentDateServiceStub.stubbedTimestamp))
                        expect(note?.updatedDate).to(beCloseTo(currentDateServiceStub.stubbedTimestamp))
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
                    useCase.repository = FailingToSaveNoteRepositoryStub()
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(FailingToSaveNoteRepositoryStub.error))
                }
            }
        }

        describe("-update:newContent:") {
            var note: Note!
            var savingRepositorySpy: SuccessfullySavingNoteRepositorySpy!

            beforeEach {
                note = Note.noteDummy()
                savingRepositorySpy = SuccessfullySavingNoteRepositorySpy()
                useCase.repository = savingRepositorySpy
            }

            it("calls save method of repository with note with updated date and content") {
                _ = useCase.update(note, newContent: "new note fixture");
                expect(savingRepositorySpy.passedNote).to(equal(note: note, withNewUpdatedDate: currentDateServiceStub.stubbedTimestamp, withNewContent: "new note fixture"))
            }

            context("when save method succedes") {
                it("returns result with updated note") {
                    let updatedNote = useCase.update(note, newContent: "new note fixture").value
                    expect(updatedNote).to(equal(note: note, withNewUpdatedDate: currentDateServiceStub.stubbedTimestamp, withNewContent: "new note fixture"))
                }
            }

            context("when save method fails") {
                beforeEach {
                    useCase.repository = FailingToSaveNoteRepositoryStub()
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(FailingToSaveNoteRepositoryStub.error))
                }
            }
        }

        describe("-update:newTitle:") {
            var note: Note!
            var savingRepositorySpy: SuccessfullySavingNoteRepositorySpy!

            beforeEach {
                note = Note.noteDummy()
                savingRepositorySpy = SuccessfullySavingNoteRepositorySpy()
                useCase.repository = savingRepositorySpy
            }

            it("calls save method of repository with note with updated date and title") {
                _ = useCase.update(note, newTitle: "new note title fixture")
                expect(savingRepositorySpy.passedNote).to(equal(note: note, withNewUpdatedDate: currentDateServiceStub.stubbedTimestamp, withNewTitle: "new note title fixture"))
            }

            context("when save method succedes") {
                it("returns result with updated note") {
                    let updatedNote = useCase.update(note, newTitle: "new note title fixture").value
                    expect(updatedNote).to(equal(note: note, withNewUpdatedDate: currentDateServiceStub.stubbedTimestamp, withNewTitle: "new note title fixture"))
                }
            }

            context("when save method fails") {
                beforeEach {
                    useCase.repository = FailingToSaveNoteRepositoryStub()
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(FailingToSaveNoteRepositoryStub.error))
                }
            }
        }

        describe("-delete") {
            let note = Note.noteDummy()
            var deletingRepositorySpy: SuccessfullyDeletingNoteRepositorySpy!

            beforeEach {
                deletingRepositorySpy = SuccessfullyDeletingNoteRepositorySpy()
                useCase.repository = deletingRepositorySpy
            }

            it("calls delete method of repository with passed note") {
                _ = useCase.delete(note)
                expect(deletingRepositorySpy.passedNote).to(equal(note))
            }

            context("when repository successes to delete note") {
                it("return result with deleted note") {
                    let result = useCase.delete(note)
                    expect(result.value).to(equal(note))
                }
            }

            context("when repository failes to delete note") {
                beforeEach() {
                    useCase.repository = FailingToDeleteNoteRepositoryStub()
                }

                it("returns result with error from repository") {
                    let error = useCase.delete(note).error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(FailingToSaveNoteRepositoryStub.error))
                }
            }
        }

        describe("-addTag:toNote:") {
            var note: Note!
            var savingRepositorySpy: SuccessfullySavingNoteRepositorySpy!

            beforeEach {
                note = Note.noteDummy()
                savingRepositorySpy = SuccessfullySavingNoteRepositorySpy()
                useCase.repository = savingRepositorySpy
            }

            it("calls save method of repository with note with updated date and tags") {
                _ = useCase.addTag(tag: "tag fixture", toNote: note)
                expect(savingRepositorySpy.passedNote).to(equal(note: note, withNewUpdatedDate: currentDateServiceStub.stubbedTimestamp, withNewTags: ["tag fixture"]))
            }

            context("when save method succedes") {
                context("when note doesnt have any tags") {
                    it("returns result with note with new tag") {
                        let updatedNote = useCase.addTag(tag: "tag fixture", toNote: note).value
                        expect(updatedNote).to(equal(note: note, withNewUpdatedDate: currentDateServiceStub.stubbedTimestamp, withNewTags: ["tag fixture"]))
                    }
                }

                context("when note already has some tags") {
                    beforeEach {
                        note = Note.noteDummyWithTags(["tag fixture"])
                    }

                    it("returns updated note with appended tag") {
                        let updatedNote = useCase.addTag(tag: "another tag fixture", toNote: note).value
                        expect(updatedNote).to(equal(note: note, withNewUpdatedDate: currentDateServiceStub.stubbedTimestamp, withNewTags: ["tag fixture", "another tag fixture"]))
                    }
                }
            }

            context("when save method fails") {
                beforeEach {
                    useCase.repository = FailingToSaveNoteRepositoryStub()
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(FailingToSaveNoteRepositoryStub.error))
                }
            }
        }

        describe("-removeTag:fromNote:") {
            var note: Note!

            beforeEach {
                note = Note.noteDummy()
            }

            context("when save method succedes") {
                beforeEach {
                    useCase.repository = SuccessfullySavingNoteRepositorySpy()
                }

                context("when note doesnt have this tag") {
                    it("returns note with without changing updatedDate") {
                        let updatedNote = useCase.removeTag(tag: "tag fixture", fromNote: note).value
                        expect(updatedNote).to(equal(note: note))
                    }
                }

                context("when note has this tag") {
                    beforeEach {
                        note = Note.noteDummyWithTags(["tag fixture", "another tag fixture"])
                    }

                    it("returns note with removed tag and new updatedDate") {
                        let updatedNote = useCase.removeTag(tag: "tag fixture", fromNote: note).value
                        expect(updatedNote).to(equal(note: note, withNewUpdatedDate: currentDateServiceStub.stubbedTimestamp, withNewTags: ["another tag fixture"]))
                    }
                }
            }

            context("when save method fails") {
                beforeEach {
                    useCase.repository = FailingToSaveNoteRepositoryStub()
                }

                it("return result with save error") {
                    let error = useCase.add(withTitle: "note title").error
                    let receivedError = error?.error as? FileNoteRepositoryError
                    expect(receivedError).to(equal(FailingToSaveNoteRepositoryStub.error))
                }
            }
        }
    }
}

// MARK: - CurrentDateServiceFake

class CurrentDateServiceStub: CurrentDateService {
    private(set) var stubbedTimestamp: Double = 20

    func date() -> Date {
        return Date(timeIntervalSince1970: stubbedTimestamp)
    }
}

// MARK: - Note repository stubs & spys

class ReturningErrorNoteRepositoryStub: NoteRepository {
    static let anyError = AnyError(error)
    static let error = FileNoteRepositoryError.failedToFindDocumentDirectory

    func getAll() -> Result<[Note], AnyError> {
        return .failure(ReturningErrorNoteRepositoryStub.anyError)
    }

    func get(noteId: String) -> Result<Note, AnyError> {
        return .failure(ReturningErrorNoteRepositoryStub.anyError)
    }

    func save(note: Note) -> Result<Note, AnyError> {
        return .failure(ReturningErrorNoteRepositoryStub.anyError)
    }

    func delete(note: Note) -> Result<Note, AnyError> {
        return .failure(ReturningErrorNoteRepositoryStub.anyError)
    }
}

class FailingToGetNoteRepositoryStub: ReturningErrorNoteRepositoryStub {}
class FailingToSaveNoteRepositoryStub: ReturningErrorNoteRepositoryStub {}
class FailingToDeleteNoteRepositoryStub: ReturningErrorNoteRepositoryStub {}

class SuccessfullySavingNoteRepositorySpy: ReturningErrorNoteRepositoryStub {
    private(set) var passedNote: Note?

    override func save(note: Note) -> Result<Note, AnyError> {
        passedNote = note
        return .success(note)
    }
}

class SuccessfullyDeletingNoteRepositorySpy: ReturningErrorNoteRepositoryStub {
    private(set) var passedNote: Note?

    override func delete(note: Note) -> Result<Note, AnyError> {
        passedNote = note
        return .success(note)
    }
}

class ReturningArrayOfNotesNoteRepositoryStub: ReturningErrorNoteRepositoryStub {
    static let notes = [Note.noteDummy(), Note.noteDummy()]

    override func getAll() -> Result<[Note], AnyError> {
        return .success(ReturningArrayOfNotesNoteRepositoryStub.notes)
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

