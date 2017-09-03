//
//  Composition.swift
//  QuNotes
//
//  Created by Alexander Guschin on 01.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

// MARK: Pipe

precedencegroup RightApplyPrecedence {
    associativity: right
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}

precedencegroup LeftApplyPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: TernaryPrecedence
}

/// Pipe Backward | Applies the function to its left to an argument on its right.
infix operator <| : RightApplyPrecedence

func <| <U, T>(function: ((T) -> U), value: T) -> U {
    return function(value)
}

/// Pipe forward | Applies an argument on the left to a function on the right.
infix operator |> : LeftApplyPrecedence

func |> <T, U>(value: T, function: ((T) -> U)) -> U {
    return function(value)
}

// MARK: Composition

precedencegroup CompositionPrecedence {
    associativity: right
    higherThan: DefaultPrecedence
}

/// Right-to-Left Composition
infix operator <<< : CompositionPrecedence

func <<< <T1, T2, T3> (left: @escaping (T2)->T3, right: @escaping (T1)->T2) -> (T1)->T3 {
    return { (t1: T1) -> T3 in return left(right(t1)) }
}

/// Left-to-Right Composition
infix operator >>> : CompositionPrecedence

func >>> <T1, T2, T3> (left: @escaping (T1)->T2, right: @escaping (T2)->T3) -> (T1)->T3 {
    return { (t1: T1) -> T3 in return right(left(t1)) }
}