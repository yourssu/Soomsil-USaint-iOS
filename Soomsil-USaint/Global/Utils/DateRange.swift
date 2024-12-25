//
//  DateRange.swift
//  Soomsil-USaint
//
//  Created by chongin on 12/23/24.
//

import Foundation

struct DateRange {
    let start: (month: Int, day: Int)
    let end: (month: Int, day: Int)

    func contains(date: (month: Int, day: Int)) -> Bool {
        let startDate = Calendar.current.date(from: DateComponents(month: start.month, day: start.day))!
        let endDate = Calendar.current.date(from: DateComponents(month: end.month, day: end.day))!
        let currentDate = Calendar.current.date(from: DateComponents(month: date.month, day: date.day))!

        if startDate <= endDate {
            return currentDate >= startDate && currentDate <= endDate
        } else {
            // 범위가 연도 경계를 넘는 경우
            return currentDate >= startDate || currentDate <= endDate
        }
    }
}

func ~= (pattern: DateRange, value: (month: Int, day: Int)) -> Bool {
    return pattern.contains(date: value)
}
