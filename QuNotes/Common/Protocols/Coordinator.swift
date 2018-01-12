//
//  Coordinator.swift
//  QuNotes
//
//  Created by Alexander Guschin on 26.08.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    associatedtype ResultEffect
    var viewController: UIViewController { get }
    var output: ResultEffect { get }
    func onStart()
    func showError(title: String, message: String)
}

extension Coordinator {
    func onStart() {
        // No op
    }

    func showError(title: Localizable, message: String) {
        let alertController = UIAlertController(title: title.localizedKey.localized,
                                                message: message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        // Need to delay to the next run loop because in the current loop
        // view controller can potentionally be not in the window hierharchy
        DispatchQueue.main.async {
            self.viewController.present(alertController, animated: true, completion: nil)
        }
    }

    func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        // Need to delay to the next run loop because in the current loop
        // view controller can potentionally be not in the window hierharchy
        DispatchQueue.main.async {
            self.viewController.present(alertController, animated: true, completion: nil)
        }
    }
}
