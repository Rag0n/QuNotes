//
//  Coordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 26.08.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

protocol Coordinator {
    var viewController: UIViewController { get }
    func onStart()
    func showError(title: String, message: String)
}

extension Coordinator {
    func onStart() {
        // No op
    }

    func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
