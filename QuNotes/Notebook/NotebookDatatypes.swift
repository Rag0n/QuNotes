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
        let filter: String
    }

    public enum Action: AutoEquatable {
        case addNote(Core.Note.Meta)
        case showNote(Core.Note.Meta, isNew: Bool)
        case deleteNote(Core.Note.Meta)
        case deleteNotebook(Core.Notebook.Meta)
        case updateNotebook(Core.Notebook.Meta, title: String)
        case finish
        case showError(title: String, message: String)
    }

    public enum ViewEffect: AutoEquatable {
        case updateAllNotes([String])
        case hideBackButton
        case showBackButton
        case updateTitle(String)
        case deleteNote(index: Int, notes: [String])
        case addNote(index: Int, notes: [String])
    }

    public enum CoordinatorEvent {
        case didUpdateNotebook(Core.Notebook.Meta, error: Error?)
        case didDeleteNotebook(error: Error?)
        case didLoadNotes([Core.Note.Meta])
        case didAddNote(Core.Note.Meta, error: Error?)
        case didDeleteNote(Core.Note.Meta, error: Error?)
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
