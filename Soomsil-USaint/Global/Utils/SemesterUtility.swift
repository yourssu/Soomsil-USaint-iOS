//
//  SemesterUtility.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 12/31/24.
//

import Foundation

class SemesterUtility {
    static let shared = SemesterUtility()
    
    /// 현재 가장 최근 학기 정보를 알려줍니다.
    /// (ex) 25년 1월 13일은 (year: 24, semester: "겨울 학기") 로 리턴됩니다.
    /// - Returns: year는 Int로, semester은 "1 학기", "여름학기", "2 학기", "겨울학기" 중 하나로 리턴됩니다.
    func currentYearAndSemester() -> (year: Int, semester: String)? {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return nil
        }

        switch (month: month, day: day) {
        case DateRange(start: (month: 6, day: 8), end: (month: 7, day: 7)):
            return (year: year, semester: "1 학기")
        case DateRange(start: (month: 7, day: 11), end: (month: 7, day: 25)):
            return (year: year, semester: "여름학기")
        case DateRange(start: (month: 12, day: 8), end: (month: 12, day: 31)):
            return (year: year, semester: "2 학기")
        case DateRange(start: (month: 1, day: 1), end: (month: 1, day: 7)):
            return (year: year - 1, semester: "2 학기")
        case DateRange(start: (month: 1, day: 11), end: (month: 1, day: 26)):
            return (year: year - 1, semester: "겨울학기")
        default:
            return nil
        }
    }
}
