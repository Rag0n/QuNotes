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
    struct Model: Codable {
        let uuid: String
        let title: String
        let content: String
    }
}

extension Experimental.Note.Model: Equatable {
    static func ==(lhs: Experimental.Note.Model, rhs: Experimental.Note.Model) -> Bool {
        return (
            lhs.uuid == rhs.uuid &&
            lhs.title == rhs.title &&
            lhs.content == rhs.content
        )
    }
}
