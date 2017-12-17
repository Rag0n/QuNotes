//
//  NavigationViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 26.08.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit

typealias CoordinatorDisposeBlock = () -> ()

final class NavigationController: UIViewController {
    // MARK: - API

    func pushCoordinator(coordinator: Coordinator, animated: Bool, onDispose: CoordinatorDisposeBlock? = nil) {
        viewControllerToCoordinatorMap[coordinator.viewController] = coordinator
        viewControllerToDisposeBlockMap[coordinator.viewController] = onDispose
        coordinator.onStart()
        pushViewController(viewController: coordinator.viewController, animated: animated)
    }

    func pushViewController(viewController: UIViewController, animated: Bool) {
        managedNavigationController.pushViewController(viewController, animated: animated)
    }

    func popViewController(animated: Bool) {
        managedNavigationController.popViewController(animated: animated)
    }

    func preferLargeTitles() {
        managedNavigationController.navigationBar.prefersLargeTitles = true
    }

    // MARK: - State

    fileprivate lazy var managedNavigationController: UINavigationController = {
        let vc = UINavigationController()
        vc.delegate = self
        return vc;
    }()

    fileprivate var viewControllerToCoordinatorMap: [UIViewController: Coordinator] = [:]
    // TODO: Probably should map Coordinator -> Block, not ViewController -> Block
    fileprivate var viewControllerToDisposeBlockMap: [UIViewController: CoordinatorDisposeBlock] = [:]

    // MARK: - Life cycle & overrides

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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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

// MARK: - UINavigationControllerDelegate

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        cleanUpChildCoordinatorsIfNeeded()
    }

    private func cleanUpChildCoordinatorsIfNeeded() {
        for vc in viewControllerToCoordinatorMap.keys {
            if shouldCleanUpCoordinator(forViewController: vc) {
                cleanUpCoordinator(forViewController: vc)
            }
        }
    }

    private func shouldCleanUpCoordinator(forViewController vc: UIViewController) -> Bool {
        return !managedNavigationController.viewControllers.contains(vc)
    }

    private func cleanUpCoordinator(forViewController viewController: UIViewController) {
        let onDisposeBlock = viewControllerToDisposeBlockMap[viewController]
        viewControllerToCoordinatorMap[viewController] = nil
        viewControllerToDisposeBlockMap[viewController] = nil
        onDisposeBlock?()
    }
}