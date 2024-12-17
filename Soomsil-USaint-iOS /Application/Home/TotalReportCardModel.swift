//
//  TotalReportCardModel.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/18/24.
//

import Foundation

public struct TotalReportCardModel: Hashable {
    let gpa: Float
    let earnedCredit: Float
    let totalCredit: Float
}

public extension Array where Element == CDTotalReportCard {
    func toTotalReportCardModel() -> TotalReportCardModel {
        TotalReportCardModel(
            gpa: Float(self.first?.gpa ?? 0),
            earnedCredit: Float(self.first?.earnedCredit ?? 0),
            totalCredit: Float(self.first?.totalCredit ?? 0)
        )
    }
}
