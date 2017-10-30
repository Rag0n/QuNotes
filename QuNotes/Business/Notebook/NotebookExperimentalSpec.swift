//
//  NotebookExperimentalSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NotebookExperimantalSpec: QuickSpec {
    override func spec() {
        let model = Experimental.Notebook.Model(uuid: "uuid", name: "name", notes: [])
        var e: Experimental.Notebook.Evaluator!

        beforeEach {
            e = Experimental.Notebook.Evaluator(model: model)
        }

        describe("-evaluate:") {
            var event: Experimental.Notebook.InputEvent!

            context("when receiving changeName event") {
                let expectedModel = Experimental.Notebook.Model(uuid: "uuid", name: "new name", notes: [])

                beforeEach {
                    event = .changeName(newName: "new name")
                }

                it("has updateModel action with new name") {
                    expect(e.evaluate(event: event).actions[0])
                        .to(equal(.updateModel(model: expectedModel)))
                }
            }
        }
    }
}
