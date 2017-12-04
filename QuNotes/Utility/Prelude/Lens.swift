//
//  Lens.swift
//  QuNotes
//
//  Created by Alexander Guschin on 02.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Part, Whole) -> Whole

    func compose<Subpart>(_ rhs: Lens<Part, Subpart>) -> Lens<Whole, Subpart> {
        return Lens<Whole, Subpart>(
            get: { rhs.get(self.get($0)) },
            set: { subPart, whole in
                let part = self.get(whole)
                let newPart = rhs.set(subPart, part)
                return self.set(newPart, whole)
            }
        )
    }

    static func zip<Part1, Part2>(
        _ a: Lens<Whole, Part1>,
        _ b: Lens<Whole, Part2>)
        -> Lens<Whole, (Part1, Part2)> where Part == (Part1, Part2) {
        return Lens<Whole, (Part1, Part2)>(
            get: { (a.get($0), b.get($0)) },
            set: { parts, whole in
                let step1 = a.set(parts.0, whole)
                return b.set(parts.1, step1)
            }
        )
    }

    static func zip<A, B, C>(_ a: Lens<Whole, A>,
                             _ b: Lens<Whole, B>,
                             _ c: Lens<Whole, C>) -> Lens<Whole, (A, B, C)> where Part == (A, B, C) {
        return Lens<Whole, (A, B, C)>(
            get: { (a.get($0), b.get($0), c.get($0)) },
            set: { parts, whole in
                let step1 = a.set(parts.0, whole)
                let step2 = b.set(parts.1, step1)
                return c.set(parts.2, step2)
            }
        )
    }
}

/**
 Infix operator of the `set` function.
 - parameter lens: A lens.
 - parameter part: A part.
 - returns: A function that transforms a whole into a new whole with a part replaced.
 */
func .~ <Whole, Part> (lens: Lens<Whole, Part>, part: Part) -> ((Whole) -> Whole) {
    return { whole in lens.set(part, whole) }
}

/**
 Infix operator of the `get` function.
 - parameter whole: A whole.
 - parameter lens:  A lens.
 - returns: A part of a whole when viewed through the lens provided.
 */
func ^* <Whole, Part> (whole: Whole, lens: Lens<Whole, Part>) -> Part {
    return lens.get(whole)
}

/**
 Infix operator of `compose`, which composes two lenses.
 - parameter lhs: A lens.
 - parameter rhs: A lens.
 - returns: The composed lens.
 */
func .. <A, B, C> (lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
    return lhs.compose(rhs)
}
