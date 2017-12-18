//
//  AppEnvironment.swift
//  QuNotes
//
//  Created by Alexander Guschin on 18.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

/// A global stack(singleton) with all global state that the app wants access to
public struct AppEnvironment {
    /// The most recent environment on the stack. Accessing current environment has effect of
    /// adding a default one onto the stack if stack is empty
    public static var current: Environment {
        guard let env = stack.last else {
            let defaultEnv = Environment()
            push(environment: defaultEnv)
            return defaultEnv
        }
        return env
    }

    /// Push a new environment onto the stack
    ///
    /// - Parameter environment: new environment
    public static func push(environment: Environment) {
        stack.append(environment)
    }

    /// Pop current environment off the stack
    ///
    /// - Returns: removed environment
    public static func pop() -> Environment? {
        return stack.popLast()
    }

    /// Replace the current environment with a new environment
    ///
    /// - Parameter env: new environment
    public static func replaceCurrent(with env: Environment) {
        push(environment: env)
        stack.remove(at: stack.count - 2)
    }

    fileprivate static var stack: [Environment] = []
}
