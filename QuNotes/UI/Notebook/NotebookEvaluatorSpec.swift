//
//  NotebookEvaluatorSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 19.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class NotebookEvaluatorSpec: QuickSpec {
    override func spec() {
        let notebook = Notebook(uuid: "uuid", name: "name")
        let e = UI.Notebook.Evaluator(withNotebook: notebook)
        let underlyingError = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "localized message"])
        let error = AnyError(underlyingError)

        describe("-evaluate:ViewControllerEvent:") {
        }

        describe("-evaluate:CoordinatorEvent:") {
        }
    }
}
