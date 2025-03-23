//
//  TabModel.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/16/25.
//

import SwiftUI

struct TabModel: Identifiable, Hashable, Equatable {
    var id: String { title }
    
    var title: String
    var size: CGSize = .zero
    var minX: CGFloat = .zero
}
