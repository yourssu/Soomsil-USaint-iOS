//
//  SaintNexus+.swift
//  Soomsil
//
//  Created by 정종인 on 1/1/24.
//  Copyright © 2024 Yourssu. All rights reserved.
//

import Foundation
import SaintNexus

public extension SNReportList {
    func toDictionaries() -> [[String: String]] {
        self.body.map { array in
            Dictionary(uniqueKeysWithValues: zip(self.header, array))
        }
    }
    func toReportListModels() -> [GradeSummaryModel] {
        let list = self.body.map { array in
            let dict = Dictionary(uniqueKeysWithValues: zip(self.header, array))
            return GradeSummaryModel.init(dict)
        }
        return list.compactMap { $0 }
    }
}
