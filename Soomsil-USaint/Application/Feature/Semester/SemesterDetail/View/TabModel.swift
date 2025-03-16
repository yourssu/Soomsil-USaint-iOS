//
//  TabModel.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/16/25.
//

import SwiftUI

struct TabModel: Identifiable {
    private(set) var id: Tab
    var size: CGSize = .zero
    var minX: CGFloat = .zero
    
    enum Tab: String, CaseIterable {
        case first = "20년 1학기"
        case second = "20년 2학기0년 2학기"
        case third = "21년 1학기"
        case fourth = "21년 2학기"
        case fifth = "22년 1학기"
        case sixth = "22년 2학기"
    }
}
