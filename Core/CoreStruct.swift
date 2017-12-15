//
//  CoreStruct.swift
//  QuNotes
//
//  Created by Alexander Guschin on 14.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation
import Prelude

public struct CoreStruct: AutoEquatable, AutoLens {
    public let name: String
    public let surname: String

    public init(name: String, surname: String) {
        self.name = name
        self.surname = surname
    }
}

func testFunc(ar: CoreStruct) -> Bool {
    return true
}

let coreStrIns = CoreStruct(name: "name", surname: "surname")

let t = coreStrIns |> testFunc

