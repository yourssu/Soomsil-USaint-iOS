//
//  ChapelCard.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 6/1/25.
//

import Foundation

enum ChapelStatus {
    case active
    case inactive
}

public struct ChapelCard: Hashable {
    let attendance: Int
    let seatPosition: String
    let floorLevel: UInt32
    var status: ChapelStatus = .active
    
    static func inactive() -> ChapelCard {
        return ChapelCard(
            attendance: 0,
            seatPosition: "이번 학기 채플 수강 없음",
            floorLevel: 0,
            status: .inactive
        )
    }
}
