//
// Created by Alexander Guschin on 17.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble

class InMemoryNoteRepositorySpec: QuickSpec {
    override func spec() {

        var noteRepository: InMemoryNoteRepository!

        beforeEach {
            noteRepository = InMemoryNoteRepository()
        }

        describe("-getAll") {
            context("when nothing is added") {
                it("returns empty array") {
                    expect(noteRepository.getAll()).to(beEmpty())
                }
            }

            context("when notes are added") {

                let firstAddedNote = Note.noteFixtureWithContent("First note fixture")
                let secondAddedNote = Note.noteFixtureWithContent("Second note fixture")

                beforeEach {
                    noteRepository.save(note: firstAddedNote)
                    noteRepository.save(note: secondAddedNote)
                }

                it("returns all added notes") {
                    let allNotes = noteRepository.getAll()
                    expect(allNotes.count).to(equal(2))
                    expect(allNotes).to(contain(firstAddedNote))
                    expect(allNotes).to(contain(secondAddedNote))
                }
            }
        }

        describe("-save") {
            it("creates new note") {
                noteRepository.save(note: Note.noteFixtureWithContent("note fixture"))
                let allNotes = noteRepository.getAll()
                expect(allNotes.first?.content).to(equal("note fixture"))
            }
        }

        describe("-delete") {

            var noteToRemove: Note!

            beforeEach {
                noteToRemove = Note.noteFixtureWithContent("note fixture")
            }

            context("when passed not was added") {

                beforeEach {
                    noteRepository.save(note: noteToRemove)
                }

                it("removes passed note") {
                    noteRepository.delete(note: noteToRemove)
                    expect(noteRepository.getAll()).to(beEmpty())
                }
            }

            context("when passed not was not added") {

                var anotherNote: Note!

                beforeEach {
                    anotherNote = Note.noteFixtureWithContent("another note")
                    noteRepository.save(note: anotherNote)
                }

                it("does nothing") {
                    noteRepository.delete(note: noteToRemove)
                    let allNotes = noteRepository.getAll()
                    expect(allNotes.count).to(equal(1))
                    expect(allNotes).to(contain(anotherNote))
                }
            }
        }
    }
}

extension Note {
    static func noteFixtureWithContent(_ content: String) -> Note {
        return Note(createdDate: 0, updatedDate: 0, content: content, title: "title", uuid: UUID.init().uuidString)
    }
}

