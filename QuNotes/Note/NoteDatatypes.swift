//
//  NoteDatatypes.swift
//  QuNotes
//
//  Created by Alexander Guschin on 15.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Result

public enum Note {
    struct Model: AutoEquatable, AutoLens {
        let title: String
        let tags: [String]
        let content: String
        let isNew: Bool
    }

    public enum Action: AutoEquatable {
        case updateTitle(title: String)
        case updateContent(content: String)
        case addTag(tag: String)
        case removeTag(tag: String)
        case deleteNote
        case finish
        case showError(title: String, message: String)
    }

    public enum ViewEffect: AutoEquatable {
        case updateTitle(title: String)
        case focusOnTitle
        case updateContent(content: String)
        case showTags(tags: [String])
        case addTag(tag: String)
        case removeTag(tag: String)
    }

    public enum CoordinatorEvent {
        case didDeleteNote(error: AnyError?)
        case didUpdateTitle(oldTitle: String, error: Error?)
        case didAddTag(tag: String, error: Error?)
        case didRemoveTag(tag: String, error: Error?)
    }

    public enum ViewEvent {
        case didLoad
        case changeContent(newContent: String)
        case changeTitle(newTitle: String)
        case delete
        case addTag(tag: String)
        case removeTag(tag: String)
    }

    public typealias ViewDispacher = (_ event: ViewEvent) -> ()
}
