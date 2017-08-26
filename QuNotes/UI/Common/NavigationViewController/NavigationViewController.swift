//
//  NavigationViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 26.08.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

final class NavigationViewController: UIViewController {

    // MARK: - API

    // MARK: - State

    private lazy var managedNavigationController: UINavigationController = {
        let vc = UINavigationController()
        vc.delegate = self
        vc.interactivePopGestureRecognizer?.delegate = self

        return vc;
    }()

    // MARK: - Life cycle

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupManagedNavigationController()
    }

    // MARK - Private

    private func setupManagedNavigationController() {
        addNavigationControllerToChildControllers()
        setupConstraintsForNavigationController()
    }

    private func addNavigationControllerToChildControllers() {
        addChildViewController(managedNavigationController)
        view.addSubview(managedNavigationController.view)
        managedNavigationController.didMove(toParentViewController: self)
    }

    private func setupConstraintsForNavigationController() {
        guard let managedNavigationView = managedNavigationController.view else { return }
        managedNavigationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            managedNavigationView.topAnchor.constraint(equalTo: view.topAnchor),
            managedNavigationView.leftAnchor.constraint(equalTo: view.leftAnchor),
            managedNavigationView.rightAnchor.constraint(equalTo: view.rightAnchor),
            managedNavigationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension NavigationViewController: UINavigationControllerDelegate {
}

extension NavigationViewController: UIGestureRecognizerDelegate {
}
