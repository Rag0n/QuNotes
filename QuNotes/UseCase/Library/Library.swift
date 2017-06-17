//
// Created by Alexander Guschin on 10.06.17.
// Copyright (c) 2017 Alexander Guschin. All rights reserved.
//

import Foundation

class Library {

    private var notebooks = [Notebook]()

    func allNotebooks() -> [Notebook] {
        return notebooks
    }

    func addNotebook(_ notebook: Notebook) {
        notebooks.append(notebook)
    }

    func removeNotebook(_ removedNotebook: Notebook) {
        if let indexOfRemovedNotebook = notebooks.index(of: removedNotebook) {
            notebooks.remove(at: indexOfRemovedNotebook)
        }
    }
}
