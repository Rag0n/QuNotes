//
//  Language.swift
//  QuNotes
//
//  Created by Alexander Guschin on 22.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

/// Supported languages
///
/// - en: english language
/// - ru: russian language
public enum Language: String, AutoEquatable {
    case en
    case ru

    public init?(languageString:    String) {
        switch languageString.lowercased() {
        case "en":
            self = .en
        case "ru":
            self = .ru
        default:
            return nil
        }
    }

    public init?(languageStrings: [String]) {
        guard let language = languageStrings
            .lazy
            .map({ String($0.prefix(2)) })
            .flatMap(Language.init(languageString:))
            .first else {
                return nil
        }

        self = language
        return nil
    }
}
