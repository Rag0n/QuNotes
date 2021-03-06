//
//  Failures.swift
//  QuNotes
//
//  Created by Alexander Guschin on 12.01.2018.
//  Copyright © 2018 Alexander Guschin. All rights reserved.
//

import Foundation

protocol Localizable {
    var localizedKey: String { get }
}

extension Library.Failure: Localizable {
    var localizedKey: String {
        switch self {
        case .addNotebook:
            return "library_adding_notebook_error"
        case .deleteNotebook:
            return "library_deleting_notebook_error"
        }
    }
}

extension Notebook.Failure: Localizable {
    var localizedKey: String {
        switch self {
        case .addNote:
            return "notebook_adding_note_error"
        case .deleteNote:
            return "notebook_deleting_note_error"
        case .deleteNotebook:
            return "notebook_deleting_error"
        case .updateNotebook:
            return "notebook_updating_title_error"
        }
    }
}

extension Note.Failure: Localizable {
    var localizedKey: String {
        switch self {
        case .addTag:
            return "note_adding_tag_error"
        case .removeTag:
            return "note_removing_tag_error"
        case .deleteNote:
            return "note_deleting_error"
        case .updateContent:
            return "note_updating_content_error"
        case .updateTitle:
            return "note_updating_title_error"
        }
    }
}
