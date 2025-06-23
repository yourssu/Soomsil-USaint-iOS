//
//  TotalReportCard.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/18/24.
//

import Foundation

public struct TotalReportCard: Hashable {
    /// 평균학점
    let gpa: Float
    // 취득학점
    let earnedCredit: Float
    /// 학부-졸업학점
    let graduateCredit: Float
    /// 전체석차
    let generalRank: Int
    /// 전체 수강생 수
    let overallStudentCount: Int
}

public extension Array where Element == CDTotalReportCard {
    func toTotalReportCard() -> TotalReportCard {
        TotalReportCard(
            gpa: Float(self.first?.gpa ?? 0),
            earnedCredit: Float(self.first?.earnedCredit ?? 0),
            graduateCredit: Float(self.first?.graduateCredit ?? 0),
            generalRank: Int(self.first?.generalRank ?? 0),
            overallStudentCount: Int(self.first?.overallStudentCount ?? 0)
        )
    }
}
