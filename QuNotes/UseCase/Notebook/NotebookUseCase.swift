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

    func getAll() -> [Notebook] {
        return repository.getAll().recover([])
    }

    func add(withName name: String) -> Result<Notebook, AnyError> {
        return repository.save <| newNotebookWithName <| name
    }

    func delete(_ notebook: Notebook) -> Result<Notebook, AnyError> {
        return repository.delete(notebook: notebook)
    }

    // MARK: - Private

    private func newNotebookWithName(name: String) -> Notebook {
        return Notebook(uuid: UUID.init().uuidString, name: name)
    }
}
