//
//  CurrentDateServiceImp.swift
//  QuNotes
//
//  Created by Alexander Guschin on 02.07.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import Foundation

struct CurrentDateServiceImp: CurrentDateService {
    func currentDate() -> Date {
        return Date()
    }
}
