//
//  LocalizedString.swift
//  QuNotes
//
//  Created by Alexander Guschin on 23.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

/// Finds a localized string for specified key
///
/// - Parameters:
///   - key: The key of the string that should be find in .strings file
///   - environment: Environment to derive the language from
/// - Returns: The localized string. If the key does not exist the `**key**` will be returned,
/// if lproj file for the language does not exist the `??key??` will be returned.
public func localizedString(key: String, environment: Environment = AppEnvironment.current) -> String {
    let lprojName = lprojFileNameForLanguage(environment.language)
    return bundle.path(forResource: lprojName, ofType: "lproj")
        .flatMap(Bundle.init(path:))
        .flatMap { $0.localizedString(forKey: key, value: "**\(key)**", table: nil) } ?? "??\(key)??"
}

private func lprojFileNameForLanguage(_ language: Language) -> String {
    return language.rawValue == "en" ? "Base" : language.rawValue
}

private class Pin {}
private let bundle = Bundle(for: Pin.self)
