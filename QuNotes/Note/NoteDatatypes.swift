//
//  NoteDatatypes.swift
//  QuNotes
//
//  Created by Alexander Guschin on 15.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Core

public enum Note {
    struct Model: AutoEquatable, AutoLens {
        let title: String
        let tags: [String]
        let cells: [Core.Note.Cell]
        let isNew: Bool
    }

    public enum Action: AutoEquatable {
        case updateTitle(String)
        case updateCells([Core.Note.Cell])
        case addTag(String)
        case removeTag(String)
        case deleteNote
        case finish
        case showFailure(Failure, reason: String)
    }

    public enum ViewEffect: AutoEquatable {
        case updateTitle(String)
        case focusOnTitle
        case updateContent(String)
        case showTags([String])
        case addTag(String)
        case removeTag(String)
    }

    public enum CoordinatorEvent {
        case didLoadContent(Core.Note.Content)
        case didDeleteNote(error: Error?)
        case didUpdateTitle(oldTitle: String, error: Error?)
        case didUpdateCells(oldCells: [Core.Note.Cell], error: Error?)
        case didAddTag(String, error: Error?)
        case didRemoveTag(String, error: Error?)
    }

    public enum ViewEvent {
        case didLoad
        case changeContent(String, index: Int)
        case changeTitle(String)
        case delete
        case addTag(String)
        case removeTag(String)
    }

    public enum CoordinatorResultEffect {
        case updateNote(Core.Note.Meta)
        case deleteNote(Core.Note.Meta)
        case none
    }

    public enum Failure: AutoEquatable {
        case deleteNote
        case updateTitle
        case updateContent
        case addTag
        case removeTag
    }

    public typealias ViewDispacher = (_ event: ViewEvent) -> ()
}
