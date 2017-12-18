//
//  Theme.swift
//  QuNotes
//
//  Created by Alexander Guschin on 18.12.2017.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

// TODO: Obviosly need to refactor property names
public protocol Theme {
    var darkColor: UIColor { get }
    var ligherDarkColor: UIColor { get }
    var mediumColor: UIColor { get }
    var mainColor: UIColor { get }
    var textColor: UIColor { get }
    var barStyle: UIBarStyle { get }
}
