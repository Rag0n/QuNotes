//
//  NotebookRepository.swift
//  QuNotes
//
//  Created by Alexander Guschin on 23.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Result

protocol NotebookRepository {
    func getAll() -> Result<[UseCase.Notebook], AnyError>
    func save(notebook: UseCase.Notebook) -> Result<UseCase.Notebook, AnyError>
    func delete(notebook: UseCase.Notebook) -> Result<UseCase.Notebook, AnyError>
}
