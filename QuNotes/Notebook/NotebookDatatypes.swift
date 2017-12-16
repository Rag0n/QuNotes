//
//  NotebookDatatypes.swift
//  QuNotes
//
//  Created by Alexander Guschin on 15.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Core

public enum Notebook {
    public struct Model: AutoEquatable, AutoLens {
        let notebook: Core.Notebook.Meta
        let notes: [Core.Note.Meta]
    }

    public enum Action: AutoEquatable {
        case addNote(note: Core.Note.Meta)
        case showNote(note: Core.Note.Meta, isNew: Bool)
        case deleteNote(note: Core.Note.Meta)
        case deleteNotebook(notebook: Core.Notebook.Meta)
        case updateNotebook(notebook: Core.Notebook.Meta, title: String)
        case finish
        case showError(title: String, message: String)
    }

    public enum ViewEffect: AutoEquatable {
        case updateAllNotes(notes: [String])
        case hideBackButton
        case showBackButton
        case updateTitle(title: String)
        case deleteNote(index: Int, notes: [String])
        case addNote(index: Int, notes: [String])
    }

    public enum CoordinatorEvent {
        case didUpdateNotebook(notebook: Core.Notebook.Meta, error: Error?)
        case didDeleteNotebook(error: Error?)
        case didLoadNotes(notes: [Core.Note.Meta])
        case didAddNote(note: Core.Note.Meta, error: Error?)
        case didDeleteNote(note: Core.Note.Meta, error: Error?)
    }

    public enum ViewEvent {
        case didLoad
        case addNote
        case selectNote(index: Int)
        case deleteNote(index: Int)
        case deleteNotebook
        case filterNotes(filter: String?)
        case didStartToEditTitle
        case didFinishToEditTitle(newTitle: String?)
    }

    public typealias ViewDispacher = (_ event: Notebook.ViewEvent) -> ()
}
