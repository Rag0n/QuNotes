//
//  URL+ExtensionsSpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 10.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble

class URLExtensionsSpec: QuickSpec {
    override func spec() {
        describe("-appendedToDocumentsURL") {
            let url = URL(string: "some/url")!

            it("inserts documents url to current url") {
                expect(url.appendedToDocumentsURL().path)
                    .to(contain("/Documents/some/url"))
            }
        }
    }
}
