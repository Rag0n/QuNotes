//
//  DefaultTheme.swift
//  QuNotes
//
//  Created by Alexander Guschin on 28.08.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

// For reference:
/* https://color.adobe.com/ru/Quiet-Cry-color-theme-9310965/edit/?copy=true&base=3&rule=Custom&selected=1&name=%D0%9A%D0%BE%D0%BF%D0%B8%D1%8F%20Quiet%20Cry&mode=rgb&rgbvalues=0.109804,0.113725,0.129412,0.192157,0.207843,0.239216,0.266667,0.345098,0.470588,0.572549,0.803922,0.811765,0.933333,0.937255,0.968627&swatchOrder=0,1,2,3,4
*/
public struct DefaultTheme: Theme {
    public var darkColor: UIColor {
        return UIColor(red: 28/255, green: 29/255, blue: 33/255, alpha: 1)
    }
    public var ligherDarkColor: UIColor {
        return UIColor(red: 49/255, green: 53/255, blue: 61/255, alpha: 1)
    }
    public var mediumColor: UIColor {
        return UIColor(red: 68/255, green: 88/255, blue: 120/255, alpha: 1)
    }
    public var mainColor: UIColor {
        return UIColor(red: 146/255, green: 205/255, blue: 207/255, alpha: 1)
    }
    public var textColor: UIColor {
        return UIColor(red: 238/255, green: 239/255, blue: 247/255, alpha: 1)
    }
    public var barStyle: UIBarStyle {
        return .black
    }

    public init() {}
}

// For reference: http://www.color-hex.com/color-palette/3046
struct GrayscaleTheme {
}
