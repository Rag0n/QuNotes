//
//  LibrarySpec.swift
//  QuNotesTests
//
//  Created by Alexander Guschin on 03.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Quick
import Nimble
import Result

class LibrarySpec: QuickSpec {
    override func spec() {
        let notebook = Dummy.notebook(uuid: "notebookUUID")
        let model = Library.Model(notebooks: [notebook])
        let error = Dummy.error(withMessage: "message")
        var e: Library.Evaluator!

        beforeEach {
            e = Library.Evaluator(model: model)
        }

        context("when initialized") {
            it("has zero effects") {
                expect(e.effects).to(beEmpty())
            }

            it("has passed model") {
                expect(e.model).to(equal(model))
            }
        }

        describe("-evaluating:") {
            var event: Library.Event!

            context("when receiving addNotebook event") {
                context("when notebook with that uuid is not added yet") {
                    let newNotebook = Dummy.notebook(uuid: "newNotebookUUID")

                    beforeEach {
                        event = .addNotebook(newNotebook)
                        e = e.evaluating(event: event)
                    }

                    it("has createNotebook effect with notebook & meta url") {
                        expect(e.effects).to(equalDiff([
                            .createNotebook(newNotebook, url: Dummy.url("newNotebookUUID.qvnotebook/meta.json"))
                        ]))
                    }

                    it("updates model by adding passed notebook") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [notebook, newNotebook])
                        ))
                    }
                }

                context("when notebook with that uuid is already added") {
                    beforeEach {
                        event = .addNotebook(notebook)
                        e = e.evaluating(event: event)
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }
                }
            }

            context("when receiving removeNotebook event") {
                context("when notebook with that uuid was added") {
                    beforeEach {
                        event = .removeNotebook(notebook)
                        e = e.evaluating(event: event)
                    }

                    it("removes notebook from model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [])
                        ))
                    }

                    it("has deleteNotebook effect with notebook url") {
                        expect(e.effects).to(equalDiff([
                            .deleteNotebook(notebook, url: Dummy.url("notebookUUID.qvnotebook"))
                        ]))
                    }
                }

                context("when notebook with that uuid was not added") {
                    beforeEach {
                        let notAddedNotebook = Dummy.notebook()
                        event = .removeNotebook(notAddedNotebook)
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }
            }

            context("when receiving loadNotebooks event") {
                beforeEach {
                    event = .loadNotebooks
                    e = e.evaluating(event: event)
                }

                it("doesnt update model") {
                    expect(e.model).to(equalDiff(model))
                }

                it("has readBaseDirectory effect") {
                    expect(e.effects).to(equalDiff([
                        .readBaseDirectory
                    ]))
                }
            }

            context("when receiving didAddNotebook event") {
                context("when successfully adds notebook") {
                    beforeEach {
                        let notebook = Dummy.notebook()
                        event = .didAddNotebook(notebook, error: nil)
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }

                context("when fails to add notebook") {
                    context("when notebook is in model") {
                        beforeEach {
                            event = .didAddNotebook(notebook, error: error)
                            e = e.evaluating(event: event)
                        }

                        it("removes notebook from model") {
                            expect(e.model).to(equalDiff(
                                Library.Model(notebooks: [])
                            ))
                        }
                    }

                    context("when notebook is not in model") {
                        beforeEach {
                            let anotherNotebook = Dummy.notebook()
                            event = .didAddNotebook(anotherNotebook, error: error)
                            e = e.evaluating(event: event)
                        }

                        it("does nothing") {
                            expect(e.model).to(equal(model))
                            expect(e.effects).to(equal([]))
                        }
                    }
                }
            }

            context("when receiving didRemoveNotebook event") {
                let removedNotebook = Dummy.notebook()

                context("when successfully removes notebook") {
                    beforeEach {
                        event = .didRemoveNotebook(removedNotebook, error: nil)
                        e = e.evaluating(event: event)
                    }

                    it("doesnt update model") {
                        expect(e.model).to(equalDiff(model))
                    }

                    it("doesnt have effects") {
                        expect(e.effects).to(beEmpty())
                    }
                }

                context("when fails to remove notebook") {
                    beforeEach {
                        event = .didRemoveNotebook(removedNotebook, error: error)
                        e = e.evaluating(event: event)
                    }

                    it("adds notebook back to model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [notebook, removedNotebook])
                        ))
                    }
                }
            }

            context("when receiving didReadBaseDirecotry event") {
                context("when successfuly reads directories") {
                    beforeEach {
                        let urls = [
                            URL(string: "/firstNotebookURL.qvnotebook")!,
                            URL(string: "/notANotebookURL")!,
                            URL(string: "/secondNotebookURL.qvnotebook")!,
                        ]
                        event = .didReadBaseDirectory(urls: Result(value: urls))
                        e = e.evaluating(event: event)
                    }

                    it("has readNotebooks effect with notebook urls & notebook meta type") {
                        expect(e.effects).to(equalDiff([
                            .readNotebooks(urls: [URL(string: "/firstNotebookURL.qvnotebook/meta.json")!,
                                                  URL(string: "/secondNotebookURL.qvnotebook/meta.json")!])
                        ]))
                    }
                }

                context("when fails to read directories") {
                    beforeEach {
                        event = .didReadBaseDirectory(urls: Result(error: error))
                        e = e.evaluating(event: event)
                    }

                    it("has handleError effect") {
                        expect(e.effects).to(equalDiff([
                            .handleError(title: "Failed to load notebooks", message: "message")
                        ]))
                    }
                }
            }

            context("when receiving didReadNotebooks event") {
                context("when notebooks list is empty") {
                    beforeEach {
                        event = .didReadNotebooks([])
                        e = e.evaluating(event: event)
                    }

                    it("has didLoadNotebooks effect with empty list") {
                        expect(e.effects).to(equalDiff([
                            .didLoadNotebooks([])
                        ]))
                    }

                    it("updates model with empty notebook list") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [])
                        ))
                    }
                }

                context("when notebooks list has result with notebook") {
                    let notebook = Dummy.notebook()

                    beforeEach {
                        event = .didReadNotebooks([Result(value: notebook)])
                        e = e.evaluating(event: event)
                    }

                    it("has didLoadNotebooks effect with 1 notebook") {
                        expect(e.effects).to(equalDiff([
                            .didLoadNotebooks([notebook])
                        ]))
                    }

                    it("updates model with notebook") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [notebook])
                        ))
                    }
                }

                context("when notebook list has result with error") {
                    beforeEach {
                        event = .didReadNotebooks([Result(error: AnyError(error))])
                        e = e.evaluating(event: event)
                    }

                    it("has handleError effect with message from error") {
                        expect(e.effects).to(equalDiff([
                            .handleError(title: "Unable to load notebooks", message: "message")
                        ]))
                    }
                }

                context("when notebook list has result with notebook and several errors") {
                    beforeEach {
                        let notebook = Dummy.notebook()
                        let secondError = Dummy.error(withMessage: "secondMessage")
                        event = .didReadNotebooks([Result(error: AnyError(error)),
                                                   Result(value: notebook),
                                                   Result(error: AnyError(secondError))])
                        e = e.evaluating(event: event)
                    }

                    it("has handleError effect with combined message from errors") {
                        expect(e.effects).to(equalDiff([
                            .handleError(title: "Unable to load notebooks", message: "message\nsecondMessage")
                        ]))
                    }
                }
            }
        }
    }
}

private enum Dummy {
    static func notebook(uuid: String = UUID().uuidString) -> Notebook.Meta {
        return Notebook.Meta(uuid: uuid, name: uuid + "name")
    }

    static func error(withMessage message: String) -> NSError {
        return NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }

    static func url(_ string: String) -> DynamicBaseURL {
        return DynamicBaseURL(url: URL(string: string)!)
    }
}
