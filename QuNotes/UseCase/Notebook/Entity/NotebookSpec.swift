//
//  NotebookSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 09.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NotebookSpec: QuickSpec {
    override func spec() {
        var notebook: Notebook!

        beforeEach {
            notebook = Notebook(uuid: "uuid", name: "name")
        }
    }
}
