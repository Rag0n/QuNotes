//
//  Composition.swift
//  QuNotes
//
//  Created by Alexander Guschin on 01.09.17.
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

///// Pipe Backward | Applies the function to its left to an argument on its right.
infix operator <| : RightApplyPrecedence

func <| <U, T>(function: ((T) -> U), value: T) -> U {
    return function(value)
}

///// Pipe forward | Applies an argument on the left to a function on the right.
infix operator |> : LeftApplyPrecedence

func |> <T, U>(value: T, function: ((T) -> U)) -> U {
    return function(value)
}
