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
        case createNotebook(Notebook.Meta, url: DynamicBaseURL)
        case deleteNotebook(Notebook.Meta, url: DynamicBaseURL)
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
        case didReadBaseDirectory(urls: Result<[URL], AnyError>)
        case didReadNotebooks([Result<Notebook.Meta, AnyError>])
    }

    public struct Evaluator {
        public let effects: [Effect]
        public let model: Model

        public init(model: Model) {
            self.model = model
            effects = []
        }

        public func evaluating(event: Event) -> Evaluator {
            var effects: [Effect] = []
            var newModel = model

            switch (event) {
            case .loadNotebooks:
                effects = [.readBaseDirectory]
            case let .addNotebook(notebook):
                guard !model.hasNotebook(withUUID: notebook.uuid) else { break }
                newModel = model |> Model.lens.notebooks .~ model.notebooks.appending(notebook)
                effects = [.createNotebook(notebook, url: notebook.metaURL())]
            case let .removeNotebook(notebookMeta):
                guard let notebook = model.notebooks.first(where: { $0.uuid == notebookMeta.uuid }) else { break }
                newModel = model |> Model.lens.notebooks .~ model.notebooks.removing(notebook)
                effects = [.deleteNotebook(notebook, url: notebook.notebookURL())]
            case let .didAddNotebook(notebook, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.notebooks .~ model.notebooks.removing(notebook)
            case let .didRemoveNotebook(notebook, error):
                guard error != nil else { break }
                newModel = model |> Model.lens.notebooks .~ model.notebooks.appending(notebook)
            case let .didReadBaseDirectory(result):
                guard let urls = result.value else {
                    effects = [.handleError(title: Constants.notebooksLoadingErrorTitle,
                                            message: result.error!.localizedDescription)]
                    break
                }
                let metaURLs = urls.filter(isNotebookURL).map(toJSONmetaURL)
                effects = [.readNotebooks(urls: metaURLs)]
            case let .didReadNotebooks(results):
                guard noErrorsInResults(results) else {
                    effects = [.handleError(title: Constants.notebooksLoadingErrorTitle,
                                            message: results |> reduceResultsToErrorSubString >>> String.init)]
                    break
                }
                newModel = model |> Model.lens.notebooks .~ results.map { $0.value! }
                effects = [.didLoadNotebooks(newModel.notebooks)]
            }

            return Evaluator(effects: effects, model: newModel)
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
        return notebooks.index { $0.uuid == notebookUUID } != nil
    }
}

internal func noErrorsInResults<T>(_ results: [Result<T, AnyError>]) -> Bool {
    return results.first(where: resultIsError) == nil
}

internal func reduceResultsToErrorSubString<T>(_ error: [Result<T, AnyError>]) -> String.SubSequence {
    return error
        .filter(resultIsError)
        .reduce("") { $0 + $1.error!.localizedDescription + "\n" }
        .dropLast()
}

internal func toJSONmetaURL(fromURL url: URL) -> URL {
    return url
        .appendingPathComponent(Notebook.Meta.Component.meta)
        .appendingPathExtension(Notebook.Meta.Extension.json)
}

private func resultIsError<T>(_ result: Result<T, AnyError>) -> Bool {
    return result.error != nil
}

private enum Constants {
    static let notebooksLoadingErrorTitle = "Failed to load notebooks"
}

private func isNotebookURL(_ url: URL) -> Bool {
    return url.pathExtension == Notebook.Meta.Extension.notebook
}
