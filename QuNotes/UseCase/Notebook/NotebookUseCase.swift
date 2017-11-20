//
//  NotebookUseCase.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

protocol HasNotebookUseCase {
    var notebookUseCase: NotebookUseCase { get }
}

class NotebookUseCase {
    // MARK: - API

    var repository: NotebookRepository!

    func getAll() -> [UseCase.Notebook] {
        return repository.getAll().recover([])
    }

    func add(withName name: String) -> Result<UseCase.Notebook, AnyError> {
        return repository.save <| newNotebookWithName <| name
    }

    func update(_ notebook: UseCase.Notebook, name: String) -> Result<UseCase.Notebook, AnyError> {
        return repository.save <| updatedNotebook(withNewName: name) <| notebook
    }

    func delete(_ notebook: UseCase.Notebook) -> Result<UseCase.Notebook, AnyError> {
        return repository.delete(notebook: notebook)
    }

    // MARK: - Private

    private func newNotebookWithName(name: String) -> UseCase.Notebook {
        return UseCase.Notebook(uuid: UUID.init().uuidString, name: name)
    }

    private func updatedNotebook(withNewName name: String) -> (UseCase.Notebook) -> UseCase.Notebook {
        return { notebook in
            return UseCase.Notebook(uuid: notebook.uuid, name: name)
        }
    }
}
