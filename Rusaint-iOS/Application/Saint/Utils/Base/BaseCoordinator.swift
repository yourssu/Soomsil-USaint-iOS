//
//  BaseCoordinator.swift
//  Rusaint-iOS
//
//  Created by 이조은 on 12/16/24.
//

import UIKit

class BaseCoordinator: NavigationCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        fatalError("Start method must be implemented")
    }

    func start(childCoordinator: Coordinator) {
        addChildCoordinator(childCoordinator)
        childCoordinator.start()
    }

    func didFinish(childCoordinator: Coordinator) {
        removeChildCoordinator(childCoordinator)
    }

    func removeChildCoordinators() {
        removeAllChildCoordinators()
    }
}
