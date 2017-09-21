//
//  NotebookUseCaseSpec.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

// MARK: - NotebookUseCaseSpec

class NotebookUseCaseSpec: QuickSpec {
    override func spec() {
        var useCase: NotebookUseCase!

        beforeEach {
            useCase = NotebookUseCase()
        }
    }
}
