// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Core

// swiftlint:disable file_length
fileprivate func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

fileprivate func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}


// MARK: - AutoEquatable for classes, protocols, structs
// MARK: - Library.Model AutoEquatable
extension Library.Model: Equatable {}
public func == (lhs: Library.Model, rhs: Library.Model) -> Bool {
    guard lhs.notebooks == rhs.notebooks else { return false }
    return true
}
// MARK: - Library.NotebookViewModel AutoEquatable
extension Library.NotebookViewModel: Equatable {}
public func == (lhs: Library.NotebookViewModel, rhs: Library.NotebookViewModel) -> Bool {
    guard lhs.title == rhs.title else { return false }
    return true
}
// MARK: - Note.CellViewModel AutoEquatable
extension Note.CellViewModel: Equatable {}
public func == (lhs: Note.CellViewModel, rhs: Note.CellViewModel) -> Bool {
    guard lhs.content == rhs.content else { return false }
    guard lhs.type == rhs.type else { return false }
    return true
}
// MARK: - Note.Model AutoEquatable
extension Note.Model: Equatable {}
internal func == (lhs: Note.Model, rhs: Note.Model) -> Bool {
    guard lhs.title == rhs.title else { return false }
    guard lhs.tags == rhs.tags else { return false }
    guard lhs.cells == rhs.cells else { return false }
    guard lhs.isNew == rhs.isNew else { return false }
    return true
}
// MARK: - Notebook.Model AutoEquatable
extension Notebook.Model: Equatable {}
public func == (lhs: Notebook.Model, rhs: Notebook.Model) -> Bool {
    guard lhs.notebook == rhs.notebook else { return false }
    guard lhs.notes == rhs.notes else { return false }
    guard lhs.filter == rhs.filter else { return false }
    guard lhs.isNew == rhs.isNew else { return false }
    return true
}
// MARK: - Notebook.NoteViewModel AutoEquatable
extension Notebook.NoteViewModel: Equatable {}
public func == (lhs: Notebook.NoteViewModel, rhs: Notebook.NoteViewModel) -> Bool {
    guard lhs.title == rhs.title else { return false }
    guard lhs.tags == rhs.tags else { return false }
    return true
}

// MARK: - AutoEquatable for Enums
// MARK: - Language AutoEquatable
extension Language: Equatable {}
public func == (lhs: Language, rhs: Language) -> Bool {
    switch (lhs, rhs) {
    case (.en, .en):
        return true
    case (.ru, .ru):
        return true
    default: return false
    }
}
// MARK: - Library.Action AutoEquatable
extension Library.Action: Equatable {}
public func == (lhs: Library.Action, rhs: Library.Action) -> Bool {
    switch (lhs, rhs) {
    case (.addNotebook(let lhs), .addNotebook(let rhs)):
        return lhs == rhs
    case (.deleteNotebook(let lhs), .deleteNotebook(let rhs)):
        return lhs == rhs
    case (.showNotebook(let lhs), .showNotebook(let rhs)):
        if lhs.0 != rhs.0 { return false }
        if lhs.isNew != rhs.isNew { return false }
        return true
    case (.showFailure(let lhs), .showFailure(let rhs)):
        if lhs.0 != rhs.0 { return false }
        if lhs.reason != rhs.reason { return false }
        return true
    default: return false
    }
}
// MARK: - Library.Failure AutoEquatable
extension Library.Failure: Equatable {}
public func == (lhs: Library.Failure, rhs: Library.Failure) -> Bool {
    switch (lhs, rhs) {
    case (.addNotebook, .addNotebook):
        return true
    case (.deleteNotebook, .deleteNotebook):
        return true
    default: return false
    }
}
// MARK: - Library.ViewEffect AutoEquatable
extension Library.ViewEffect: Equatable {}
public func == (lhs: Library.ViewEffect, rhs: Library.ViewEffect) -> Bool {
    switch (lhs, rhs) {
    case (.updateAllNotebooks(let lhs), .updateAllNotebooks(let rhs)):
        return lhs == rhs
    case (.addNotebook(let lhs), .addNotebook(let rhs)):
        if lhs.index != rhs.index { return false }
        if lhs.notebooks != rhs.notebooks { return false }
        return true
    case (.deleteNotebook(let lhs), .deleteNotebook(let rhs)):
        if lhs.index != rhs.index { return false }
        if lhs.notebooks != rhs.notebooks { return false }
        return true
    default: return false
    }
}
// MARK: - Note.Action AutoEquatable
extension Note.Action: Equatable {}
public func == (lhs: Note.Action, rhs: Note.Action) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lhs), .updateTitle(let rhs)):
        return lhs == rhs
    case (.updateCells(let lhs), .updateCells(let rhs)):
        return lhs == rhs
    case (.addTag(let lhs), .addTag(let rhs)):
        return lhs == rhs
    case (.removeTag(let lhs), .removeTag(let rhs)):
        return lhs == rhs
    case (.deleteNote, .deleteNote):
        return true
    case (.finish, .finish):
        return true
    case (.showFailure(let lhs), .showFailure(let rhs)):
        if lhs.0 != rhs.0 { return false }
        if lhs.reason != rhs.reason { return false }
        return true
    case (.didUpdateNote(let lhs), .didUpdateNote(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - Note.Failure AutoEquatable
extension Note.Failure: Equatable {}
public func == (lhs: Note.Failure, rhs: Note.Failure) -> Bool {
    switch (lhs, rhs) {
    case (.deleteNote, .deleteNote):
        return true
    case (.updateTitle, .updateTitle):
        return true
    case (.updateContent, .updateContent):
        return true
    case (.addTag, .addTag):
        return true
    case (.removeTag, .removeTag):
        return true
    default: return false
    }
}
// MARK: - Note.ViewEffect AutoEquatable
extension Note.ViewEffect: Equatable {}
public func == (lhs: Note.ViewEffect, rhs: Note.ViewEffect) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lhs), .updateTitle(let rhs)):
        return lhs == rhs
    case (.focusOnTitle, .focusOnTitle):
        return true
    case (.updateCell(let lhs), .updateCell(let rhs)):
        if lhs.index != rhs.index { return false }
        if lhs.cells != rhs.cells { return false }
        return true
    case (.addCell(let lhs), .addCell(let rhs)):
        if lhs.index != rhs.index { return false }
        if lhs.cells != rhs.cells { return false }
        return true
    case (.removeCell(let lhs), .removeCell(let rhs)):
        if lhs.index != rhs.index { return false }
        if lhs.cells != rhs.cells { return false }
        return true
    case (.updateCells(let lhs), .updateCells(let rhs)):
        return lhs == rhs
    case (.showTags(let lhs), .showTags(let rhs)):
        return lhs == rhs
    case (.addTag(let lhs), .addTag(let rhs)):
        return lhs == rhs
    case (.removeTag(let lhs), .removeTag(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - Notebook.Action AutoEquatable
extension Notebook.Action: Equatable {}
public func == (lhs: Notebook.Action, rhs: Notebook.Action) -> Bool {
    switch (lhs, rhs) {
    case (.addNote(let lhs), .addNote(let rhs)):
        return lhs == rhs
    case (.showNote(let lhs), .showNote(let rhs)):
        if lhs.0 != rhs.0 { return false }
        if lhs.isNew != rhs.isNew { return false }
        return true
    case (.deleteNote(let lhs), .deleteNote(let rhs)):
        return lhs == rhs
    case (.deleteNotebook, .deleteNotebook):
        return true
    case (.updateNotebook(let lhs), .updateNotebook(let rhs)):
        return lhs == rhs
    case (.finish, .finish):
        return true
    case (.showFailure(let lhs), .showFailure(let rhs)):
        if lhs.0 != rhs.0 { return false }
        if lhs.reason != rhs.reason { return false }
        return true
    case (.didUpdateNotebook(let lhs), .didUpdateNotebook(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - Notebook.Failure AutoEquatable
extension Notebook.Failure: Equatable {}
public func == (lhs: Notebook.Failure, rhs: Notebook.Failure) -> Bool {
    switch (lhs, rhs) {
    case (.addNote, .addNote):
        return true
    case (.deleteNote, .deleteNote):
        return true
    case (.deleteNotebook, .deleteNotebook):
        return true
    case (.updateNotebook, .updateNotebook):
        return true
    default: return false
    }
}
// MARK: - Notebook.ViewEffect AutoEquatable
extension Notebook.ViewEffect: Equatable {}
public func == (lhs: Notebook.ViewEffect, rhs: Notebook.ViewEffect) -> Bool {
    switch (lhs, rhs) {
    case (.updateAllNotes(let lhs), .updateAllNotes(let rhs)):
        return lhs == rhs
    case (.hideBackButton, .hideBackButton):
        return true
    case (.showBackButton, .showBackButton):
        return true
    case (.updateTitle(let lhs), .updateTitle(let rhs)):
        return lhs == rhs
    case (.deleteNote(let lhs), .deleteNote(let rhs)):
        if lhs.index != rhs.index { return false }
        if lhs.notes != rhs.notes { return false }
        return true
    case (.addNote(let lhs), .addNote(let rhs)):
        if lhs.index != rhs.index { return false }
        if lhs.notes != rhs.notes { return false }
        return true
    case (.focusOnTitle, .focusOnTitle):
        return true
    default: return false
    }
}
