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
        case addNotebook(notebook: Core.Notebook.Model)
        case deleteNotebook(notebook: Core.Notebook.Meta)
        case updateNotebook(notebook: Core.Notebook.Meta)
        case showNotebook(notebook: Core.Notebook.Meta)
        case reloadNotebook(notebook: Core.Notebook.Meta)
        case showError(title: String, message: String)
    }

    public enum ViewEffect: AutoEquatable {
        case updateAllNotebooks(notebooks: [NotebookViewModel])
        case addNotebook(index: Int, notebooks: [NotebookViewModel])
        case updateNotebook(index: Int, notebooks:  [NotebookViewModel])
        case deleteNotebook(index: Int, notebooks: [NotebookViewModel])
    }

    public enum CoordinatorEvent {
        case didLoadNotebooks(notebooks: [Core.Notebook.Meta])
        case didAddNotebook(notebook: Core.Notebook.Meta, error: Error?)
        case didDeleteNotebook(notebook: Core.Notebook.Meta, error: Error?)
        case didFinishShowing(notebook: Core.Notebook.Meta)
    }

    public enum ViewEvent {
        case addNotebook
        case selectNotebook(index: Int)
        case deleteNotebook(index: Int)
        case updateNotebook(index: Int, title: String)
    }

    public struct NotebookViewModel: AutoEquatable {
        let title: String
        let isEditable: Bool
    }

    public typealias ViewDispacher = (_ event: ViewEvent) -> ()
}
