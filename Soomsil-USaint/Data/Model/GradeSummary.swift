//
//  GradeSummaryModel.swift
//  Soomsil-USaint-iOS
//
//  Created by 최지우 on 12/17/24.
//

import Foundation

import Rusaint

public struct GradeSummary: Hashable {
    let year: Int
    let semester: String
    var gpa: Float
    let earnedCredit: Float
    let semesterRank: Int
    let semesterStudentCount: Int
    let overallRank: Int
    let overallStudentCount: Int
    var lectures: [LectureDetail]?

    init(
        year: Int,
        semester: String,
        gpa: Float,
        earnedCredit: Float,
        semesterRank: Int,
        semesterStudentCount: Int,
        overallRank: Int,
        overallStudentCount: Int,
        lectures: [LectureDetail]?
    ) {
        self.year = year
        self.semester = semester
        self.gpa = gpa
        self.earnedCredit = earnedCredit
        self.semesterRank = semesterRank
        self.semesterStudentCount = semesterStudentCount
        self.overallRank = overallRank
        self.overallStudentCount = overallStudentCount
        self.lectures = lectures
    }

    init(year: Int, semester: String) {
        self.year = year
        self.semester = semester
        self.gpa = 0
        self.earnedCredit = 0
        self.semesterRank = 0
        self.semesterStudentCount = 0
        self.overallRank = 0
        self.overallStudentCount = 0
        self.lectures = nil
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public static func == (lhs: GradeSummary, rhs: GradeSummary) -> Bool {
        lhs.id == rhs.id
    }
}

extension GradeSummary: Identifiable {
    public var id: String {
        "\(self.year) \(self.semester)"
    }
}

public extension GradeSummary {
    static let semesterOrder = ["1 학기", "여름학기", "2 학기", "겨울학기"]
}

public extension Array where Element == GradeSummary {
    func sortedAscending() -> Self {
        self.sorted(by: compareReportModelsAscending)
    }
    func sortedDescending() -> Self {
        self.sorted(by: compareReportModelsDescending)
    }
    private func compareReportModelsDescending(_ model1: GradeSummary, _ model2: GradeSummary) -> Bool {
        let year1 = model1.year
        let year2 = model2.year

        if year1 != year2 {
            return year1 > year2
        } else {
            if let index1 = GradeSummary.semesterOrder.firstIndex(of: model1.semester),
               let index2 = GradeSummary.semesterOrder.firstIndex(of: model2.semester) {
                return index1 > index2
            }
        }

        return false
    }
    private func compareReportModelsAscending(_ model1: GradeSummary, _ model2: GradeSummary) -> Bool {
        let year1 = model1.year
        let year2 = model2.year

        if year1 != year2 {
            return year1 < year2
        } else {
            if let index1 = GradeSummary.semesterOrder.firstIndex(of: model1.semester),
               let index2 = GradeSummary.semesterOrder.firstIndex(of: model2.semester) {
                return index1 < index2
            }
        }
        return false
    }
}

public extension Array where Element == CDSemester {
    func toGradeSummaryModel() -> [GradeSummary] {
        self.map {
            GradeSummary(
                year: Int($0.year),
                semester: $0.semester ?? "",
                gpa: $0.gpa,
                earnedCredit: $0.earnedCredit,
                semesterRank: Int($0.semesterRank),
                semesterStudentCount: Int($0.semesterStudentCount),
                overallRank: Int($0.overallRank),
                overallStudentCount: Int($0.overallStudentCount),
                lectures: $0.lectures.toLectureDetails()
            )
        }
    }
}

public extension Array where Element == Rusaint.SemesterGrade {
    func toGradeSummaryModels() -> [GradeSummary] {
        self.map {
            GradeSummary(
                year: Int($0.year),
                semester: $0.semester.toString(),
                gpa: $0.gradePointsAverage,
                earnedCredit: $0.earnedCredits,
                semesterRank: Int($0.semesterRank.first),
                semesterStudentCount: Int($0.semesterRank.second),
                overallRank: Int($0.generalRank.first),
                overallStudentCount: Int($0.generalRank.second),
                lectures: nil
            )
        }
    }
}

public extension CDSemester {
    func toGradeSummaryModel() -> GradeSummary {
        GradeSummary(
            year: Int(self.year),
            semester: self.semester ?? "",
            gpa: self.gpa,
            earnedCredit: self.earnedCredit,
            semesterRank: Int(self.semesterRank),
            semesterStudentCount: Int(self.semesterStudentCount),
            overallRank: Int(self.overallRank),
            overallStudentCount: Int(self.overallStudentCount),
            lectures: self.lectures.toLectureDetails()
        )
    }
}


