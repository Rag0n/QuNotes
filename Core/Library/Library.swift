//
//  Library.swift
//  QuNotes
//
//  Created by Alexander Guschin on 03.11.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result
import Prelude

public enum Library {
    public struct Model: AutoEquatable, AutoLens {
        public let notebooks: [Notebook.Meta]

        public init(notebooks: [Notebook.Meta]) {
            self.notebooks = notebooks
        }
    }

    public enum Effect: AutoEquatable {
        case createNotebook(Notebook.Meta, url: URL)
        case deleteNotebook(Notebook.Meta, url: URL)
        case readBaseDirectory
        case readNotebooks(urls: [URL])
        case handleError(title: String, message: String)
        case didLoadNotebooks([Notebook.Meta])
    }

    public enum Event {
        case loadNotebooks
        case addNotebook(Notebook.Meta)
        case removeNotebook(Notebook.Meta)
        case didAddNotebook(Notebook.Meta, error: Error?)
        case didRemoveNotebook(Notebook.Meta, error: Error?)
        case didReadBaseDirectory(urls: Result<[URL], NSError>)
        case didReadNotebooks([Result<Notebook.Meta, AnyError>])
    }

    public struct Evaluator {
        public let effects: [Effect]
        public let model: Model

        public init(model: Model) {
            self.model = model
            effects = []
        }

        public func evaluate(event: Event) -> Evaluator {
            var effects: [Effect] = []
            var modelUpdate = { (oldModel: Library.Model) in return self.model }

            switch (event) {
            case .loadNotebooks:
                effects = [.readBaseDirectory]
            case let .addNotebook(notebook):
                guard !model.hasNotebook(withUUID: notebook.uuid) else { break }
                modelUpdate = Model.lens.notebooks .~ model.notebooks.appending(notebook)
                effects = [.createNotebook(notebook, url: notebook.metaURL())]
            case let .removeNotebook(notebookMeta):
                guard let notebook = model.notebooks.first(where: { $0.uuid == notebookMeta.uuid }) else { break }
                modelUpdate = Model.lens.notebooks .~ model.notebooks.removing(notebook)
                effects = [.deleteNotebook(notebook, url: notebook.notebookURL())]
            case let .didAddNotebook(notebook, error):
                guard error != nil else { break }
                modelUpdate = Model.lens.notebooks .~ model.notebooks.removing(notebook)
            case let .didRemoveNotebook(notebook, error):
                guard error != nil else { break }
                modelUpdate = Model.lens.notebooks .~ model.notebooks.appending(notebook)
            case let .didReadBaseDirectory(result):
                guard let urls = result.value else {
                    effects = [.handleError(title: "Failed to load notebooks",
                                            message: result.error!.localizedDescription)]
                    break
                }
                let metaURLs = urls
                    .filter { $0.pathExtension == "qvnotebook" }
                    .map { $0.appendingPathComponent("meta").appendingPathExtension("json") }
                effects = [.readNotebooks(urls: metaURLs)]
            case let .didReadNotebooks(results):
                let errors = results.filter { $0.error != nil }
                if errors.count > 0 {
                    var errorMessage = errors.reduce("") { $0 + $1.error!.localizedDescription + "\n" }
                    errorMessage = String(errorMessage.dropLast(1))
                    effects = [.handleError(title: "Unable to load notebooks", message: errorMessage)]
                    break
                }
                let notebooks = results.map { $0.value! }
                effects = [.didLoadNotebooks(notebooks)]
            }

            return Evaluator(effects: effects, model: modelUpdate(model))
        }

        private init(effects: [Effect], model: Model) {
            self.model = model
            self.effects = effects
        }
    }
}

// MARL: - Private

private extension Library.Model {
    func hasNotebook(withUUID notebookUUID: String) -> Bool {
        return notebooks.filter({ $0.uuid == notebookUUID }).count > 0
    }
}
