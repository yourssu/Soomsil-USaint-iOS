//
//  SaintHomeCoordinator.swift
//  Soomsil
//
//  Created by 정종인 on 2023/05/22.
//  Copyright © 2023 Yourssu. All rights reserved.
//

import UIKit
import YDS
import SaintNexus
import SwiftUI

final class SaintHomeCoordinator: BaseCoordinator {
    override func start() {
        let viewModel = DefaultSaintHomeViewModel()
        let viewController = UIHostingController(rootView: SaintHomeView(viewModel: viewModel))
        navigationController.pushViewController(viewController, animated: false)
        navigationController.navigationBar.backIndicatorImage = YDSIcon.arrowLeftLine
        navigationController.navigationBar.tintColor = YDSColor.buttonNormal

        if navigationController.tabBarItem.image == nil {
            navigationController.tabBarItem = UITabBarItem(
                title: " ",
                image: YDSIcon.rankLine,
                selectedImage: YDSIcon.rankFilled
            )
        }
    }
}
