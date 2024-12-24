//
//  GradeSummaryModel.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/17/24.
//

import Foundation
import Rusaint

public struct GradeSummaryModel: Identifiable, Hashable {
    public let id = UUID()
    let year: Int
    let semester: String
    let gpa: Float
    let earnedCredit: Float
    let semesterRank: Int
    let semesterStudentCount: Int
    let overallRank: Int
    let overallStudentCount: Int
    var lectures: [LectureDetailModel]?
    
    init(
        year: Int,
        semester: String,
        gpa: Float,
        earnedCredit: Float,
        semesterRank: Int,
        semesterStudentCount: Int,
        overallRank: Int,
        overallStudentCount: Int,
        lectures: [LectureDetailModel]?
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

//    init?(_ dict: [String: String]) {
//        guard let year = dict["학년도"],
//              let semester = dict["학기"],
//              let credit = Double(dict["취득학점"]!),
//              let pfCredit = Double(dict["P/F학점"]!),
//              let gpa = Double(dict["평점평균"]!),
//              let semesterRank = dict["학기별석차"],
//              let totalRank = dict["전체석차"]
//        else { return nil }
//        self.year = year
//        self.semester = semester
//        self.credit = credit
//        self.pfCredit = pfCredit
//        self.gpa = gpa
//        self.semesterRank = semesterRank.tupleOfSplittedString
//        self.totalRank = totalRank.tupleOfSplittedString
//    }

    init(year: Int, semester: String) {
        self.year = year
        self.semester = semester
        self.gpa = 0
        self.earnedCredit = 0
        self.semesterRank = 0
        self.semesterStudentCount = 0
        self.overallRank = 0
        self.overallStudentCount = 0
        self.lectures = []
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public static func == (lhs: GradeSummaryModel, rhs: GradeSummaryModel) -> Bool {
        lhs.id == rhs.id
    }
}

public extension GradeSummaryModel {
    static let semesterOrder = ["1 학기", "여름학기", "2 학기", "겨울학기"]
}

public extension Array where Element == GradeSummaryModel {
//    var averageGPA: Double {
//        var creditSum = 0.0
//        var gpaSum = 0.0
//        self.forEach { report in
//            let credit = report.credit - report.pfCredit
//            creditSum += credit
//            gpaSum += credit * report.gpa
//        }
//        return gpaSum == 0 ? 0.0 : round((gpaSum / creditSum) * 100) / 100
//    }
    func sortedAscending() -> Self {
        self.sorted(by: compareReportModelsAscending)
    }
    func sortedDescending() -> Self {
        self.sorted(by: compareReportModelsDescending)
    }
    private func compareReportModelsDescending(_ model1: GradeSummaryModel, _ model2: GradeSummaryModel) -> Bool {
        let year1 = model1.year
        let year2 = model2.year
        
        if year1 != year2 {
            return year1 > year2
        } else {
            if let index1 = GradeSummaryModel.semesterOrder.firstIndex(of: model1.semester),
               let index2 = GradeSummaryModel.semesterOrder.firstIndex(of: model2.semester) {
                return index1 > index2
            }
        }
        
        return false
    }
    private func compareReportModelsAscending(_ model1: GradeSummaryModel, _ model2: GradeSummaryModel) -> Bool {
        let year1 = model1.year
        let year2 = model2.year
        
        if year1 != year2 {
            return year1 < year2
        } else {
            if let index1 = GradeSummaryModel.semesterOrder.firstIndex(of: model1.semester),
               let index2 = GradeSummaryModel.semesterOrder.firstIndex(of: model2.semester) {
                return index1 < index2
            }
        }
        
        return false
    }
}

public extension Array where Element == CDSemester {
    func toGradeSummaryModel() -> [GradeSummaryModel] {
        self.map {
            GradeSummaryModel(
                year: Int($0.year),
                semester: $0.semester ?? "",
                gpa: $0.gpa,
                earnedCredit: $0.earnedCredit,
                semesterRank: Int($0.semesterRank),
                semesterStudentCount: Int($0.semesterStudentCount),
                overallRank: Int($0.overallRank),
                overallStudentCount: Int($0.overallStudentCount),
                lectures: [LectureDetailModel(code: "", title: "", credit: 0.0, score: "", grade: .empty, professorName: "")]
            )
        }
    }
}

public extension Array where Element == Rusaint.SemesterGrade {
    func toGradeSummaryModels() -> [GradeSummaryModel] {
        self.map {
            GradeSummaryModel(
                year: Int($0.year),
                semester: $0.semester,
                gpa: $0.gradePointsAvarage,
                earnedCredit: $0.earnedCredits,
                semesterRank: Int($0.semesterRank.first),
                semesterStudentCount: Int($0.semesterRank.second),
                overallRank: Int($0.generalRank.first),
                overallStudentCount: Int($0.generalRank.second),
                lectures: [LectureDetailModel(code: "", title: "", credit: 0.0, score: "", grade: .empty, professorName: "")]
            )
        }
    }
}

public extension CDSemester {
    func toGradeSummaryModel() -> GradeSummaryModel {
        GradeSummaryModel(
            year: Int(self.year),
            semester: self.semester ?? "",
            gpa: self.gpa,
            earnedCredit: self.earnedCredit,
            semesterRank: Int(self.semesterRank),
            semesterStudentCount: Int(self.semesterStudentCount),
            overallRank: Int(self.overallRank),
            overallStudentCount: Int(self.overallStudentCount),
            lectures: (self.lectures?.allObjects as? [CDLecture])?.compactMap { lecture in
                LectureDetailModel(
                    code: lecture.code ?? "Unknown Code",
                    title: lecture.title ?? "Unknown Title",
                    credit: Double(lecture.credit),
                    score: lecture.score ?? "N/A",
                    grade: Grade(rawValue: lecture.grade ?? "") ?? .empty,
                    professorName: lecture.professorName ?? "Unknown Professor"
                )
            } ?? []
        )
    }
}

