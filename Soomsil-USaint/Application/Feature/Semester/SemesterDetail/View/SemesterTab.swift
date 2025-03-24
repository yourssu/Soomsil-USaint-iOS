//
//  SemesterTab.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/16/25.
//

import SwiftUI

struct SemesterTab: Identifiable, Hashable, Equatable {
    var id: String
    var size: CGSize = .zero
    var minX: CGFloat = .zero
    
    static func dummyTab() -> [SemesterTab] {
        [
           .init(id: "20년 1학기"),
           .init(id: "21년 2학기2학기"),
           .init(id: "21년 1학기"),
           .init(id: "21년 2학기21년 2학기"),
           .init(id: "22년 1학기"),
           .init(id: "22년 2학기"),
       ]
    }
}
