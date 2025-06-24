//
//  SemesterTab.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/16/25.
//

import SwiftUI

struct SemesterTab: Identifiable, Hashable, Equatable {
    let uuid = UUID() // 같은 id(학기 이름)을 가진 SemesterTab이 새로고침 등으로 새로 만들어졌을 때, ForEach가 이 변화를 알게 하기 위한 id입니다.
    var id: String
    var size: CGSize = .zero
    var minX: CGFloat = .zero
}
