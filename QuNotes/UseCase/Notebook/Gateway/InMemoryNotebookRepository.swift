//
//  InMemoryNotebookRepository.swift
//  QuNotes
//
//  Created by Alexander Guschin on 23.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

class InMemoryNotebookRepository: NotebookRepository {
    // MARK: - API

    func getAll() -> Result<[Notebook], AnyError> {
        return .success(notebooks)
    }

    func save(notebook: Notebook) -> Result<Notebook, AnyError> {
        notebooks.append(notebook)
        return .success(notebook)
    }

    func delete(notebook: Notebook) -> Result<Notebook, AnyError> {
        notebooks.remove(object: notebook)
        return .success(notebook)
    }

    // MARK: - Private

    private var notebooks = [Notebook]()
}
