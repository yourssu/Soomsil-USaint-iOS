//
//  SemesterType+.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 3/28/25.
//

import Rusaint

extension SemesterType {
    func toString() -> String {
        switch self {
        case .one:
            return "1 학기"
        case .two:
            return "2 학기"
        case .summer:
            return "여름학기"
        case .winter:
            return "겨울학기"
        }
    }
}
