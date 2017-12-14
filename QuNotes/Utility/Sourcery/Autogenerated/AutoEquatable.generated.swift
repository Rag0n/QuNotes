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
// MARK: - Library.Model AutoEquatable
extension Library.Model: Equatable {}
internal func == (lhs: Library.Model, rhs: Library.Model) -> Bool {
    guard lhs.notebooks == rhs.notebooks else { return false }
    return true
}
// MARK: - Note.Content AutoEquatable
extension Note.Content: Equatable {}
internal func == (lhs: Note.Content, rhs: Note.Content) -> Bool {
    guard lhs.content == rhs.content else { return false }
    return true
}
// MARK: - Note.Meta AutoEquatable
extension Note.Meta: Equatable {}
internal func == (lhs: Note.Meta, rhs: Note.Meta) -> Bool {
    guard lhs.uuid == rhs.uuid else { return false }
    guard lhs.title == rhs.title else { return false }
    guard lhs.tags == rhs.tags else { return false }
    guard lhs.updated_at == rhs.updated_at else { return false }
    guard lhs.created_at == rhs.created_at else { return false }
    return true
}
// MARK: - Note.Model AutoEquatable
extension Note.Model: Equatable {}
internal func == (lhs: Note.Model, rhs: Note.Model) -> Bool {
    guard lhs.meta == rhs.meta else { return false }
    guard lhs.content == rhs.content else { return false }
    guard lhs.notebook == rhs.notebook else { return false }
    return true
}
// MARK: - Notebook.Meta AutoEquatable
extension Notebook.Meta: Equatable {}
internal func == (lhs: Notebook.Meta, rhs: Notebook.Meta) -> Bool {
    guard lhs.uuid == rhs.uuid else { return false }
    guard lhs.name == rhs.name else { return false }
    return true
}
// MARK: - Notebook.Model AutoEquatable
extension Notebook.Model: Equatable {}
internal func == (lhs: Notebook.Model, rhs: Notebook.Model) -> Bool {
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
// MARK: - UI.Note.Model AutoEquatable
extension UI.Note.Model: Equatable {}
internal func == (lhs: UI.Note.Model, rhs: UI.Note.Model) -> Bool {
    guard lhs.meta == rhs.meta else { return false }
    guard lhs.content == rhs.content else { return false }
    guard lhs.isNew == rhs.isNew else { return false }
    return true
}
// MARK: - UI.Notebook.Model AutoEquatable
extension UI.Notebook.Model: Equatable {}
internal func == (lhs: UI.Notebook.Model, rhs: UI.Notebook.Model) -> Bool {
    guard lhs.notebook == rhs.notebook else { return false }
    guard lhs.notes == rhs.notes else { return false }
    return true
}

// MARK: - AutoEquatable for Enums
// MARK: - Library.Effect AutoEquatable
extension Library.Effect: Equatable {}
internal func == (lhs: Library.Effect, rhs: Library.Effect) -> Bool {
    switch (lhs, rhs) {
    case (.createNotebook(let lhs), .createNotebook(let rhs)):
        if lhs.notebook != rhs.notebook { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.deleteNotebook(let lhs), .deleteNotebook(let rhs)):
        if lhs.notebook != rhs.notebook { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.readBaseDirectory, .readBaseDirectory):
        return true
    case (.readNotebooks(let lhs), .readNotebooks(let rhs)):
        return lhs == rhs
    case (.handleError(let lhs), .handleError(let rhs)):
        if lhs.title != rhs.title { return false }
        if lhs.message != rhs.message { return false }
        return true
    case (.didLoadNotebooks(let lhs), .didLoadNotebooks(let rhs)):
        return lhs == rhs
    default: return false
    }
}
// MARK: - Note.Effect AutoEquatable
extension Note.Effect: Equatable {}
internal func == (lhs: Note.Effect, rhs: Note.Effect) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lhs), .updateTitle(let rhs)):
        if lhs.note != rhs.note { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.updateContent(let lhs), .updateContent(let rhs)):
        if lhs.content != rhs.content { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.addTag(let lhs), .addTag(let rhs)):
        if lhs.note != rhs.note { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.removeTag(let lhs), .removeTag(let rhs)):
        if lhs.note != rhs.note { return false }
        if lhs.url != rhs.url { return false }
        return true
    default: return false
    }
}
// MARK: - Notebook.Effect AutoEquatable
extension Notebook.Effect: Equatable {}
internal func == (lhs: Notebook.Effect, rhs: Notebook.Effect) -> Bool {
    switch (lhs, rhs) {
    case (.createNote(let lhs), .createNote(let rhs)):
        if lhs.note != rhs.note { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.updateNotebook(let lhs), .updateNotebook(let rhs)):
        if lhs.notebook != rhs.notebook { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.deleteNote(let lhs), .deleteNote(let rhs)):
        if lhs.note != rhs.note { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.readDirectory(let lhs), .readDirectory(let rhs)):
        return lhs == rhs
    case (.readNotes(let lhs), .readNotes(let rhs)):
        return lhs == rhs
    case (.handleError(let lhs), .handleError(let rhs)):
        if lhs.title != rhs.title { return false }
        if lhs.message != rhs.message { return false }
        return true
    case (.didLoadNotes(let lhs), .didLoadNotes(let rhs)):
        return lhs == rhs
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
    case (.updateNotebook(let lhs), .updateNotebook(let rhs)):
        return lhs == rhs
    case (.showNotebook(let lhs), .showNotebook(let rhs)):
        return lhs == rhs
    case (.reloadNotebook(let lhs), .reloadNotebook(let rhs)):
        return lhs == rhs
    case (.showError(let lhs), .showError(let rhs)):
        if lhs.title != rhs.title { return false }
        if lhs.message != rhs.message { return false }
        return true
    default: return false
    }
}
// MARK: - UI.Library.ViewEffect AutoEquatable
extension UI.Library.ViewEffect: Equatable {}
internal func == (lhs: UI.Library.ViewEffect, rhs: UI.Library.ViewEffect) -> Bool {
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
// MARK: - UI.Note.ViewEffect AutoEquatable
extension UI.Note.ViewEffect: Equatable {}
internal func == (lhs: UI.Note.ViewEffect, rhs: UI.Note.ViewEffect) -> Bool {
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
    case (.addNote(let lhs), .addNote(let rhs)):
        return lhs == rhs
    case (.showNote(let lhs), .showNote(let rhs)):
        if lhs.note != rhs.note { return false }
        if lhs.isNew != rhs.isNew { return false }
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
// MARK: - UI.Notebook.ViewEffect AutoEquatable
extension UI.Notebook.ViewEffect: Equatable {}
internal func == (lhs: UI.Notebook.ViewEffect, rhs: UI.Notebook.ViewEffect) -> Bool {
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
    default: return false
    }
}
