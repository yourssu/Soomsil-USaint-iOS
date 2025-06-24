//
//  String+.swift
//  Soomsil-USaint
//
//  Created by 박현수 on 6/24/25.
//

import Foundation

import Rusaint

extension String {
    func toSemesterType() -> SemesterType {
        switch self {
        case "1 학기": return .one
        case "2 학기": return .two
        case "여름학기": return .summer
        case "겨울학기": return .winter
        default:
            debugPrint("\(#function) | Unsupported semester type \(self), 1학기로 매핑됩니다.")
            return .one
        }
    }
}
