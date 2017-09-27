//
//  LibraryViewModel.swift
//  QuNotes
//
//  Created by Alexander Guschin on 24.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

struct NotebookCellViewModel {
    let title: String
    let isEditable: Bool
}

struct LibraryViewModel {
    let notebooks: [NotebookCellViewModel]
}
