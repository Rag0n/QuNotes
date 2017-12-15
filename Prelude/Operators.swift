//
//  Operators.swift
//  QuNotesPrelude
//
//  Created by Alexander Guschin on 14.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

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

precedencegroup CompositionPrecedence {
    associativity: right
    higherThan: LeftApplyPrecedence
}

precedencegroup LensCompositionPrecedence {
    associativity: left
    higherThan: LensSetPrecedence
}

precedencegroup LensSetPrecedence {
    associativity: left
    higherThan: CompositionPrecedence
}

// MARK: Pipe

/// Pipe Backward | Applies the function to its left to an argument on its right.
infix operator <| : RightApplyPrecedence

public func <| <U, T>(function: ((T) -> U), value: T) -> U {
    return function(value)
}

/// Pipe forward | Applies an argument on the left to a function on the right.
infix operator |> : LeftApplyPrecedence

public func |> <T, U>(value: T, function: ((T) -> U)) -> U {
    return function(value)
}

// MARK: Composition

/// Right-to-Left Composition
public func <| <T1, T2, T3> (left: @escaping (T2)->T3, right: @escaping (T1)->T2) -> (T1)->T3 {
    return { (t1: T1) -> T3 in return left(right(t1)) }
}

/// Left-to-Right Composition
public func |>  <T1, T2, T3> (left: @escaping (T1)->T2, right: @escaping (T2)->T3) -> (T1)->T3 {
    return { (t1: T1) -> T3 in return right(left(t1)) }
}

// MARK: Lens

/// Lens composition
infix operator .. : LensCompositionPrecedence
/// Lens get
infix operator ^* : LeftApplyPrecedence
/// Lens set
infix operator .~ : LensSetPrecedence
