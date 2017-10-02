//
//  FileNotebookRepository.swift
//  QuNotes
//
//  Created by Alexander Guschin on 02.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

class FileNotebookRepository: NotebookRepository {
    // MARK: - API

    func getAll() -> Result<[Notebook], AnyError> {
        return .success([])
    }

    func save(notebook: Notebook) -> Result<Notebook, AnyError> {
        return .success(notebook)
    }

    func delete(notebook: Notebook) -> Result<Notebook, AnyError> {
        return .success(notebook)
    }
}
