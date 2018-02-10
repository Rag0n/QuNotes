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

    func pushCoordinator<C: Coordinator>(coordinator: C, animated: Bool, onDispose: CoordinatorDisposeBlock? = nil) {
        let vc = coordinator.viewController
        viewControllerToCoordinatorMap[vc] = coordinator
        viewControllerToDisposeBlockMap[vc] = onDispose
        coordinator.onStart()
        managedNavigationController.pushViewController(vc, animated: animated)
    }

    func popCoordinator(animated: Bool) {
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

    // TODO: AnyObject is actually a Coordinator type
    fileprivate var viewControllerToCoordinatorMap: [UIViewController: AnyObject] = [:]
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

    private func cleanUpCoordinator(forViewController vc: UIViewController) {
        let onDisposeBlock = viewControllerToDisposeBlockMap[vc]
        viewControllerToCoordinatorMap[vc] = nil
        viewControllerToDisposeBlockMap[vc] = nil
        onDisposeBlock?()
    }
}
