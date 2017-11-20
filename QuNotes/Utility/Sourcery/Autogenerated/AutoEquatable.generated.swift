// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

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
// MARK: - Experimental.Library.Model AutoEquatable
extension Experimental.Library.Model: Equatable {}
internal func == (lhs: Experimental.Library.Model, rhs: Experimental.Library.Model) -> Bool {
    guard lhs.notebooks == rhs.notebooks else { return false }
    return true
}
// MARK: - Experimental.Note.Content AutoEquatable
extension Experimental.Note.Content: Equatable {}
internal func == (lhs: Experimental.Note.Content, rhs: Experimental.Note.Content) -> Bool {
    guard lhs.content == rhs.content else { return false }
    return true
}
// MARK: - Experimental.Note.Meta AutoEquatable
extension Experimental.Note.Meta: Equatable {}
internal func == (lhs: Experimental.Note.Meta, rhs: Experimental.Note.Meta) -> Bool {
    guard lhs.uuid == rhs.uuid else { return false }
    guard lhs.title == rhs.title else { return false }
    guard lhs.tags == rhs.tags else { return false }
    guard lhs.updated_at == rhs.updated_at else { return false }
    guard lhs.created_at == rhs.created_at else { return false }
    return true
}
// MARK: - Experimental.Note.Model AutoEquatable
extension Experimental.Note.Model: Equatable {}
internal func == (lhs: Experimental.Note.Model, rhs: Experimental.Note.Model) -> Bool {
    guard lhs.meta == rhs.meta else { return false }
    guard lhs.content == rhs.content else { return false }
    guard compareOptionals(lhs: lhs.notebook, rhs: rhs.notebook, compare: ==) else { return false }
    return true
}
// MARK: - Experimental.Notebook.Meta AutoEquatable
extension Experimental.Notebook.Meta: Equatable {}
internal func == (lhs: Experimental.Notebook.Meta, rhs: Experimental.Notebook.Meta) -> Bool {
    guard lhs.uuid == rhs.uuid else { return false }
    guard lhs.name == rhs.name else { return false }
    return true
}
// MARK: - Experimental.Notebook.Model AutoEquatable
extension Experimental.Notebook.Model: Equatable {}
internal func == (lhs: Experimental.Notebook.Model, rhs: Experimental.Notebook.Model) -> Bool {
    guard lhs.meta == rhs.meta else { return false }
    guard lhs.notes == rhs.notes else { return false }
    return true
}
// MARK: - UI.Library.Model AutoEquatable
extension UI.Library.Model: Equatable {}
internal func == (lhs: UI.Library.Model, rhs: UI.Library.Model) -> Bool {
    guard lhs.notebooks == rhs.notebooks else { return false }
    return true
}
// MARK: - UI.Library.NotebookViewModel AutoEquatable
extension UI.Library.NotebookViewModel: Equatable {}
internal func == (lhs: UI.Library.NotebookViewModel, rhs: UI.Library.NotebookViewModel) -> Bool {
    guard lhs.title == rhs.title else { return false }
    guard lhs.isEditable == rhs.isEditable else { return false }
    return true
}

// MARK: - AutoEquatable for Enums
// MARK: - Experimental.Library.Action AutoEquatable
extension Experimental.Library.Action: Equatable {}
internal func == (lhs: Experimental.Library.Action, rhs: Experimental.Library.Action) -> Bool {
    switch (lhs, rhs) {
    case (.createNotebook(let lhs), .createNotebook(let rhs)):
        if lhs.notebook != rhs.notebook { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.deleteNotebook(let lhs), .deleteNotebook(let rhs)):
        if lhs.notebook != rhs.notebook { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.readFiles(let lhs), .readFiles(let rhs)):
        if lhs.url != rhs.url { return false }
        if lhs.extension != rhs.extension { return false }
        return true
    default: return false
    }
}
// MARK: - UI.Library.Action AutoEquatable
extension UI.Library.Action: Equatable {}
internal func == (lhs: UI.Library.Action, rhs: UI.Library.Action) -> Bool {
    switch (lhs, rhs) {
    case (.addNotebook(let lhs), .addNotebook(let rhs)):
        return lhs == rhs
    case (.deleteNotebook(let lhs), .deleteNotebook(let rhs)):
        return lhs == rhs
    case (.showNotes(let lhs), .showNotes(let rhs)):
        return lhs == rhs
    case (.showError(let lhs), .showError(let rhs)):
        if lhs.title != rhs.title { return false }
        if lhs.message != rhs.message { return false }
        return true
    default: return false
    }
}
// MARK: - UI.Library.ViewControllerEffect AutoEquatable
extension UI.Library.ViewControllerEffect: Equatable {}
internal func == (lhs: UI.Library.ViewControllerEffect, rhs: UI.Library.ViewControllerEffect) -> Bool {
    switch (lhs, rhs) {
    case (.updateAllNotebooks(let lhs), .updateAllNotebooks(let rhs)):
        return lhs == rhs
    case (.addNotebook(let lhs), .addNotebook(let rhs)):
        if lhs.index != rhs.index { return false }
        if lhs.notebooks != rhs.notebooks { return false }
        return true
    case (.updateNotebook(let lhs), .updateNotebook(let rhs)):
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
// MARK: - UI.Note.Action AutoEquatable
extension UI.Note.Action: Equatable {}
internal func == (lhs: UI.Note.Action, rhs: UI.Note.Action) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lhs), .updateTitle(let rhs)):
        return lhs == rhs
    case (.updateContent(let lhs), .updateContent(let rhs)):
        return lhs == rhs
    case (.addTag(let lhs), .addTag(let rhs)):
        return lhs == rhs
    case (.removeTag(let lhs), .removeTag(let rhs)):
        return lhs == rhs
    case (.deleteNote, .deleteNote):
        return true
    case (.finish, .finish):
        return true
    case (.showError(let lhs), .showError(let rhs)):
        if lhs.title != rhs.title { return false }
        if lhs.message != rhs.message { return false }
        return true
    default: return false
    }
}
// MARK: - UI.Note.ViewControllerEffect AutoEquatable
extension UI.Note.ViewControllerEffect: Equatable {}
internal func == (lhs: UI.Note.ViewControllerEffect, rhs: UI.Note.ViewControllerEffect) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lhs), .updateTitle(let rhs)):
        return lhs == rhs
    case (.focusOnTitle, .focusOnTitle):
        return true
    case (.updateContent(let lhs), .updateContent(let rhs)):
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
// MARK: - UI.Notebook.Action AutoEquatable
extension UI.Notebook.Action: Equatable {}
internal func == (lhs: UI.Notebook.Action, rhs: UI.Notebook.Action) -> Bool {
    switch (lhs, rhs) {
    case (.addNote, .addNote):
        return true
    case (.showNote(let lhs), .showNote(let rhs)):
        if lhs.note != rhs.note { return false }
        if lhs.isNewNote != rhs.isNewNote { return false }
        return true
    case (.deleteNote(let lhs), .deleteNote(let rhs)):
        return lhs == rhs
    case (.deleteNotebook(let lhs), .deleteNotebook(let rhs)):
        return lhs == rhs
    case (.updateNotebook(let lhs), .updateNotebook(let rhs)):
        if lhs.notebook != rhs.notebook { return false }
        if lhs.title != rhs.title { return false }
        return true
    case (.finish, .finish):
        return true
    case (.showError(let lhs), .showError(let rhs)):
        if lhs.title != rhs.title { return false }
        if lhs.message != rhs.message { return false }
        return true
    default: return false
    }
}
// MARK: - UI.Notebook.ViewControllerEffect AutoEquatable
extension UI.Notebook.ViewControllerEffect: Equatable {}
internal func == (lhs: UI.Notebook.ViewControllerEffect, rhs: UI.Notebook.ViewControllerEffect) -> Bool {
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
    default: return false
    }
}
