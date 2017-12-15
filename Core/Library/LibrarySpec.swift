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
        let notebook = Notebook.Model(meta: Notebook.Meta(uuid: "notebookUUID", name: "notebookName"),
                                      notes: [])
        let model = Library.Model(notebooks: [notebook])
        let error = NSError(domain: "error domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "message"])
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

        describe("-evaluate:") {
            var event: Library.Event!

            context("when receiving addNotebook event") {
                context("when notebook with that uuid is not added yet") {
                    let newNotebook = Notebook.Model(meta: Notebook.Meta(uuid: "newNotebookUUID", name: "newNotebookName"), notes: [])

                    beforeEach {
                        event = .addNotebook(notebook: newNotebook)
                        e = e.evaluate(event: event)
                    }

                    it("has createNotebook effect with notebook & meta url") {
                        expect(e.effects).to(equalDiff([
                            .createNotebook(notebook: newNotebook,
                                             url: URL(string: "newNotebookUUID.qvnotebook/meta.json")!)
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
                        event = .addNotebook(notebook: notebook)
                        e = e.evaluate(event: event)
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
                        event = .removeNotebook(notebook: notebook.meta)
                        e = e.evaluate(event: event)
                    }

                    it("removes notebook from model") {
                        expect(e.model).to(equalDiff(
                            Library.Model(notebooks: [])
                        ))
                    }

                    it("has deleteNotebook effect with notebook url") {
                        expect(e.effects).to(equalDiff([
                            .deleteNotebook(notebook: notebook,
                                            url: URL(string: "notebookUUID.qvnotebook")!)
                        ]))
                    }
                }

                context("when notebook with that uuid was not added") {
                    beforeEach {
                        let notAddedNotebook = Notebook.Model(meta: Notebook.Meta(uuid: "nAUUID", name: "nAName"), notes: [])
                        event = .removeNotebook(notebook: notAddedNotebook.meta)
                        e = e.evaluate(event: event)
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
                    e = e.evaluate(event: event)
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
                        let notebook = Notebook.Model(meta: Notebook.Meta(uuid: "notebookUUID", name: "notebookName"), notes: [])
                        event = .didAddNotebook(notebook: notebook, error: nil)
                        e = e.evaluate(event: event)
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
                            event = .didAddNotebook(notebook: notebook, error: error)
                            e = e.evaluate(event: event)
                        }

                        it("removes notebook from model") {
                            expect(e.model).to(equalDiff(
                                Library.Model(notebooks: [])
                            ))
                        }
                    }

                    context("when notebook is not in model") {
                        beforeEach {
                            let anotherNotebook = Notebook.Model(meta: Notebook.Meta(uuid: "aUUID", name: "aName"), notes: [])
                            event = .didAddNotebook(notebook: anotherNotebook, error: error)
                            e = e.evaluate(event: event)
                        }

                        it("does nothing") {
                            expect(e.model).to(equal(model))
                            expect(e.effects).to(equal([]))
                        }
                    }
                }
            }

            context("when receiving didRemoveNotebook event") {
                let removedNotebook = Notebook.Model(meta: Notebook.Meta(uuid: "removedUUID", name: "removeName"), notes: [])

                context("when successfully removes notebook") {
                    beforeEach {
                        event = .didRemoveNotebook(notebook: removedNotebook, error: nil)
                        e = e.evaluate(event: event)
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
                        event = .didRemoveNotebook(notebook: removedNotebook, error: error)
                        e = e.evaluate(event: event)
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
                        e = e.evaluate(event: event)
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
                        e = e.evaluate(event: event)
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
                        event = .didReadNotebooks(notebooks: [])
                        e = e.evaluate(event: event)
                    }

                    it("has didLoadNotebooks effect with empty list") {
                        expect(e.effects).to(equalDiff([
                            .didLoadNotebooks(notebooks: [])
                        ]))
                    }
                }

                context("when notebooks list has result with notebook") {
                    beforeEach {
                        let notebook = Notebook.Meta(uuid: "uuid", name: "name")
                        event = .didReadNotebooks(notebooks: [Result(value: notebook)])
                        e = e.evaluate(event: event)
                    }

                    it("has didLoadNotebooks effect with 1 notebook") {
                        expect(e.effects).to(equalDiff([
                            .didLoadNotebooks(notebooks: [Notebook.Meta(uuid: "uuid", name: "name")])
                        ]))
                    }
                }

                context("when notebook list has result with error") {
                    beforeEach {
                        event = .didReadNotebooks(notebooks: [Result(error: AnyError(error))])
                        e = e.evaluate(event: event)
                    }

                    it("has handleError effect with message from error") {
                        expect(e.effects).to(equalDiff([
                            .handleError(title: "Unable to load notebooks", message: "message")
                        ]))
                    }
                }

                context("when notebook list has result with notebook and several errors") {
                    beforeEach {
                        let notebook = Notebook.Meta(uuid: "uuid", name: "name")
                        let secondError = NSError(domain: "error domain", code: 1,
                                                  userInfo: [NSLocalizedDescriptionKey: "secondMessage"])
                        event = .didReadNotebooks(notebooks: [Result(error: AnyError(error)),
                                                              Result(value: notebook),
                                                              Result(error: AnyError(secondError))])
                        e = e.evaluate(event: event)
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
