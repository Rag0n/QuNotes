//
//  NotebookRepository.swift
//  QuNotes
//
//  Created by Alexander Guschin on 23.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Result

protocol NotebookRepository {
    func getAll() -> Result<[Notebook], AnyError>
    func save(notebook: Notebook) -> Result<Notebook, AnyError>
    func delete(notebook: Notebook) -> Result<Notebook, AnyError>
}
