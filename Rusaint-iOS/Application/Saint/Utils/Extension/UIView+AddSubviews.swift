//
//  UIView+AddSubviews.swift
//  SaintKit
//
//  Created by Gyuni on 2021/12/18.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views { addSubview(view) }
    }
}
