//
//  TotalReportCard.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/18/24.
//

import Foundation

public struct TotalReportCard: Hashable {
    let gpa: Float
    let earnedCredit: Float
    let graduateCredit: Float
}

public extension Array where Element == CDTotalReportCard {
    func toTotalReportCard() -> TotalReportCard {
        TotalReportCard(
            gpa: Float(self.first?.gpa ?? 0),
            earnedCredit: Float(self.first?.earnedCredit ?? 0),
            graduateCredit: Float(self.first?.graduateCredit ?? 0)
        )
    }
}
