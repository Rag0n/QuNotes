//
//  NoteExperimental.swift
//  QuNotes
//
//  Created by Alexander Guschin on 30.10.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

extension Experimental {
    enum Note {}
}

extension Experimental.Note {
    struct Model {
        let uuid: String
        let title: String
        let content: String
        let notebook: Experimental.Notebook.Model?

        init(uuid: String,
             title: String,
             content: String,
             notebook: Experimental.Notebook.Model? = nil) {
            self.uuid = uuid
            self.title = title
            self.content = content
            self.notebook = notebook
        }
    }

    struct Meta: Codable {
        let uuid: String
        let title: String
    }

    struct Content: Codable {
        let content: String
    }
}

// MARK: Datatypes equatable

extension Experimental.Note.Model: Equatable {
    static func ==(lhs: Experimental.Note.Model, rhs: Experimental.Note.Model) -> Bool {
        return (
            lhs.uuid == rhs.uuid &&
            lhs.title == rhs.title &&
            lhs.content == rhs.content
        )
    }
}

extension Experimental.Note.Meta: Equatable {
    static func ==(lhs: Experimental.Note.Meta, rhs: Experimental.Note.Meta) -> Bool {
        return (
            lhs.uuid == rhs.uuid &&
            lhs.title == rhs.title
        )
    }
}

extension Experimental.Note.Content: Equatable {
    static func ==(lhs: Experimental.Note.Content, rhs: Experimental.Note.Content) -> Bool {
        return lhs.content == rhs.content
    }
}
