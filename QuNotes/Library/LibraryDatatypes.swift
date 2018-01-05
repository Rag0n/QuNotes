//
//  LibraryDatatypes.swift
//  QuNotes
//
//  Created by Alexander Guschin on 15.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Core

public enum Library {
    public struct Model: AutoEquatable, AutoLens {
        let notebooks: [Core.Notebook.Meta]
    }

    public enum Action: AutoEquatable {
        case addNotebook(Core.Notebook.Meta)
        case deleteNotebook(Core.Notebook.Meta)
        case showNotebook(Core.Notebook.Meta)
        case showError(title: String, message: String)
    }

    public enum ViewEffect: AutoEquatable {
        case updateAllNotebooks([NotebookViewModel])
        case addNotebook(index: Int, notebooks: [NotebookViewModel])
        case deleteNotebook(index: Int, notebooks: [NotebookViewModel])
    }

    public enum CoordinatorEvent {
        case updateNotebook(Core.Notebook.Meta)
        case deleteNotebook(Core.Notebook.Meta)
        case didLoadNotebooks([Core.Notebook.Meta])
        case didAddNotebook(Core.Notebook.Meta, error: Error?)
        case didDeleteNotebook(Core.Notebook.Meta, error: Error?)
    }

    public enum ViewEvent {
        case addNotebook
        case selectNotebook(index: Int)
        case deleteNotebook(index: Int)
    }

    public struct NotebookViewModel: AutoEquatable {
        let title: String

        public init(title: String) {
            self.title = title
        }
    }

    public enum CoordinatorResultEffect {
        case none
    }

    public typealias ViewDispacher = (_ event: ViewEvent) -> ()
}
