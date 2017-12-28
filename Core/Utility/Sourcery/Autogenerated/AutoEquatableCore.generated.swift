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
public func == (lhs: Library.Model, rhs: Library.Model) -> Bool {
    guard lhs.notebooks == rhs.notebooks else { return false }
    return true
}
// MARK: - Note.Meta AutoEquatable
extension Note.Meta: Equatable {}
public func == (lhs: Note.Meta, rhs: Note.Meta) -> Bool {
    guard lhs.uuid == rhs.uuid else { return false }
    guard lhs.title == rhs.title else { return false }
    guard lhs.tags == rhs.tags else { return false }
    guard lhs.updated_at == rhs.updated_at else { return false }
    guard lhs.created_at == rhs.created_at else { return false }
    return true
}
// MARK: - Note.Model AutoEquatable
extension Note.Model: Equatable {}
public func == (lhs: Note.Model, rhs: Note.Model) -> Bool {
    guard lhs.meta == rhs.meta else { return false }
    guard lhs.content == rhs.content else { return false }
    guard lhs.notebook == rhs.notebook else { return false }
    return true
}
// MARK: - Notebook.Meta AutoEquatable
extension Notebook.Meta: Equatable {}
public func == (lhs: Notebook.Meta, rhs: Notebook.Meta) -> Bool {
    guard lhs.uuid == rhs.uuid else { return false }
    guard lhs.name == rhs.name else { return false }
    return true
}
// MARK: - Notebook.Model AutoEquatable
extension Notebook.Model: Equatable {}
public func == (lhs: Notebook.Model, rhs: Notebook.Model) -> Bool {
    guard lhs.meta == rhs.meta else { return false }
    guard lhs.notes == rhs.notes else { return false }
    return true
}

// MARK: - AutoEquatable for Enums
// MARK: - Library.Effect AutoEquatable
extension Library.Effect: Equatable {}
public func == (lhs: Library.Effect, rhs: Library.Effect) -> Bool {
    switch (lhs, rhs) {
    case (.createNotebook(let lhs), .createNotebook(let rhs)):
        if lhs.0 != rhs.0 { return false }
        if lhs.url != rhs.url { return false }
        return true
    case (.deleteNotebook(let lhs), .deleteNotebook(let rhs)):
        if lhs.0 != rhs.0 { return false }
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
public func == (lhs: Note.Effect, rhs: Note.Effect) -> Bool {
    switch (lhs, rhs) {
    case (.updateTitle(let lhs), .updateTitle(let rhs)):
        if lhs.note != rhs.note { return false }
        if lhs.url != rhs.url { return false }
        if lhs.oldTitle != rhs.oldTitle { return false }
        return true
    case (.updateContent(let lhs), .updateContent(let rhs)):
        if lhs.content != rhs.content { return false }
        if lhs.url != rhs.url { return false }
        if lhs.oldContent != rhs.oldContent { return false }
        return true
    case (.addTag(let lhs), .addTag(let rhs)):
        if lhs.note != rhs.note { return false }
        if lhs.url != rhs.url { return false }
        if lhs.tag != rhs.tag { return false }
        return true
    case (.removeTag(let lhs), .removeTag(let rhs)):
        if lhs.note != rhs.note { return false }
        if lhs.url != rhs.url { return false }
        if lhs.tag != rhs.tag { return false }
        return true
    default: return false
    }
}
// MARK: - Notebook.Effect AutoEquatable
extension Notebook.Effect: Equatable {}
public func == (lhs: Notebook.Effect, rhs: Notebook.Effect) -> Bool {
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
