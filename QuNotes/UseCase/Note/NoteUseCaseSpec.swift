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
        }
    }
}
