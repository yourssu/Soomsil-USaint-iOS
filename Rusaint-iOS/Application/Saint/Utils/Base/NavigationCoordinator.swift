//
//  NavigationCoordinator.swift
//  Rusaint-iOS
//
//  Created by 이조은 on 12/16/24.
//

import UIKit

protocol NavigationCoordinator: Coordinator {
    var navigationController: UINavigationController { get }
}
