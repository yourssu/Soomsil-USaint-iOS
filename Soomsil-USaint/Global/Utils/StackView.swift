//
//  StackView.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/18/24.
//

import Foundation

enum StackViewType {
    case SemesterList
    case SemesterDetail
    case Setting
    case WebViewTerm
    case WebViewPrivacy
}

struct StackView: Hashable {
    let type: StackViewType

    init(type: StackViewType) {
        self.type = type
    }
}
