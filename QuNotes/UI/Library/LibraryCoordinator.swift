//
//  LibraryCoordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 21.09.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

class LibraryCoordinator: Coordinator {
    // MARK: - Coordinator

    func onStart() {
    }

    var rootViewController: UIViewController {
        get {
            return libraryViewController
        }
    }

    // MARK: - Life cycle

    fileprivate lazy var libraryViewController: LibraryViewController = {
        let vc = LibraryViewController()
        return vc
    }()
}
