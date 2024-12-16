//
//  UIStackView+AddArrangedSubviews.swift
//  SaintKit
//
//  Created by Gyuni on 2021/12/18.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        for view in views { addArrangedSubview(view) }
    }
}
