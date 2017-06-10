//
//  main.swift
//  QuNotes
//
//  Created by Alexander Guschin on 10.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate.self) : nil
}

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    nil,
    delegateClassName()
)
