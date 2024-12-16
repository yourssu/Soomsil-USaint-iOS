//
//  ReportModel.swift
//  Soomsil
//
//  Created by 정종인 on 2023/06/03.
//  Copyright © 2023 Yourssu. All rights reserved.
//

import Foundation

public struct ReportSummaryModel: Identifiable, Hashable {
    public let id = UUID()
    let year: String
    let semester: String
    let credit: Double
    let pfCredit: Double
    let semesterGPA: Double
    let semesterRank: (String, String)
    let totalRank: (String, String)

    init(
        year: String,
        semester: String,
        credit: Double,
        pfCredit: Double,
        semesterGPA: Double,
        semesterRank: (String, String),
        totalRank: (String, String)
    ) {
        self.year = year
        self.semester = semester
        self.credit = credit
        self.pfCredit = pfCredit
        self.semesterGPA = semesterGPA
        self.semesterRank = semesterRank
        self.totalRank = totalRank
    }

    init?(_ dict: [String: String]) {
        guard let year = dict["학년도"],
              let semester = dict["학기"],
              let credit = Double(dict["취득학점"]!),
              let pfCredit = Double(dict["P/F학점"]!),
              let semesterGPA = Double(dict["평점평균"]!),
              let semesterRank = dict["학기별석차"],
              let totalRank = dict["전체석차"]
        else { return nil }
        self.year = year
        self.semester = semester
        self.credit = credit
        self.pfCredit = pfCredit
        self.semesterGPA = semesterGPA
        self.semesterRank = semesterRank.tupleOfSplittedString
        self.totalRank = totalRank.tupleOfSplittedString
    }

    init(year: String, semester: String) {
        self.year = year
        self.semester = semester
        self.credit = 0
        self.pfCredit = 0
        self.semesterGPA = 0
        self.semesterRank = ("-", "-")
        self.totalRank = ("-", "-")
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public static func == (lhs: ReportSummaryModel, rhs: ReportSummaryModel) -> Bool {
        lhs.id == rhs.id
    }
}

public extension ReportSummaryModel {
    static let semesterOrder = ["1 학기", "여름학기", "2 학기", "겨울학기"]
}

public extension Array where Element == ReportSummaryModel {
    var averageGPA: Double {
        var creditSum = 0.0
        var gpaSum = 0.0
        self.forEach { report in
            let credit = report.credit - report.pfCredit
            creditSum += credit
            gpaSum += credit * report.semesterGPA
        }
        return gpaSum == 0 ? 0.0 : round((gpaSum / creditSum) * 100) / 100
    }
    func sortedAscending() -> Self {
        self.sorted(by: compareReportModelsAscending)
    }
    func sortedDescending() -> Self {
        self.sorted(by: compareReportModelsDescending)
    }
    private func compareReportModelsDescending(_ model1: ReportSummaryModel, _ model2: ReportSummaryModel) -> Bool {
        if let year1 = Int(model1.year), let year2 = Int(model2.year) {
            if year1 != year2 {
                return year1 > year2
            } else {
                if let index1 = ReportSummaryModel.semesterOrder.firstIndex(of: model1.semester),
                   let index2 = ReportSummaryModel.semesterOrder.firstIndex(of: model2.semester) {
                    return index1 > index2
                }
            }
        }
        return false
    }
    private func compareReportModelsAscending(_ model1: ReportSummaryModel, _ model2: ReportSummaryModel) -> Bool {
        if let year1 = Int(model1.year), let year2 = Int(model2.year) {
            if year1 != year2 {
                return year1 < year2
            } else {
                if let index1 = ReportSummaryModel.semesterOrder.firstIndex(of: model1.semester),
                   let index2 = ReportSummaryModel.semesterOrder.firstIndex(of: model2.semester) {
                    return index1 < index2
                }
            }
        }
        return false
    }
}

public extension Array where Element == CDReportSummary {
    func toReportSummaryModel() -> [ReportSummaryModel] {
        self.map {
            ReportSummaryModel(
                year: $0.year ?? "",
                semester: $0.semester ?? "",
                credit: $0.credit,
                pfCredit: $0.pfCredit,
                semesterGPA: $0.semesterGPA,
                semesterRank: $0.semesterRank?.tupleOfSplittedString ?? ("-", "-"),
                totalRank: $0.totalRank?.tupleOfSplittedString ?? ("-", "-")
            )
        }
    }
}
