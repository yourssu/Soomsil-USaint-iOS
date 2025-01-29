//
//  TotalReportCard.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 1/29/25.
//

import SwiftData

@Model
final class TotalReportCardTestModel {
    var earnedCredit: Double
    var gpa: Double
    var graduateCredit: Double
    
    init(earnedCredit: Double, gpa: Double, graduateCredit: Double) {
        self.earnedCredit = earnedCredit
        self.gpa = gpa
        self.graduateCredit = graduateCredit
    }
}
