//
//  UINavigationController+.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 3/26/25.
//

import UIKit

extension UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
