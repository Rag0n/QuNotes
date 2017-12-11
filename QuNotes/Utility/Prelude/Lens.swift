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
