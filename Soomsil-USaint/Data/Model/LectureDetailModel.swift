//
//  LectureDetailModel.swift
//  Soomsil-USaint-iOS
//
//  Created by 최지우 on 12/19/24.
//

import Foundation
import Rusaint

public struct LectureDetailModel {
    let code: String
    let title: String
    let credit: Double
    let score: String
    let grade: Grade
    let professorName: String
}

enum Grade: String {
    case aPlus = "A+"
    case aZero = "A0"
    case aMinus = "A-"
    case bPlus = "B+"
    case bZero = "B0"
    case bMinus = "B-"
    case cPlus = "C+"
    case cZero = "C0"
    case cMinus = "C-"
    case dPlus = "D+"
    case dZero = "D0"
    case dMinus = "D-"
    case pass = "P"
    case fail = "F"
    case unknown = "Unknown"
    case empty = "empty"

    var string: String {
        self.rawValue
    }

    var gpa: Double {
        switch self {
        case .aPlus:
            return 4.5
        case .aZero:
            return 4.3
        case .aMinus:
            return 4.0
        case .bPlus:
            return 3.5
        case .bZero:
            return 3.3
        case .bMinus:
            return 3.0
        case .cPlus:
            return 2.5
        case .cZero:
            return 2.3
        case .cMinus:
            return 2.0
        case .dPlus:
            return 1.5
        case .dZero:
            return 1.3
        case .dMinus:
            return 1.0
        case .pass:
            return 0.0
        case .fail:
            return 0.0
        case .unknown:
            return 0.0
        case .empty:
            return 0.0
        }
    }
}

//extension CDReportDetail {
//    func toReportDetailModel() -> ReportDetailModel {
//        return ReportDetailModel(
//            year: self.year ?? "",
//            semester: self.semester ?? "",
//            lectures: (self.lectures?.allObjects as? [CDLecture] ?? []).map { lecture in
//                ReportDetailModel.Lecture(
//                    code: lecture.code ?? "",
//                    title: lecture.title ?? "",
//                    credit: lecture.credit,
//                    score: lecture.score ?? "",
//                    grade: .init(rawValue: lecture.grade ?? "") ?? .unknown,
//                    professorName: lecture.professorName ?? ""
//                )
//            }
//        )
//    }
//}

public extension Array where Element == Rusaint.ClassGrade {
    func toLectureDetailModels() -> [LectureDetailModel] {
        self.map {
            LectureDetailModel(code: $0.code,
                               title: $0.className,
                               credit: Double($0.gradePoints),
                               score: classScoreToString($0.score),
                               grade: Grade(rawValue: $0.rank) ?? .unknown,
                               professorName: $0.professor)
        }
    }
    
    func classScoreToString(_ classScore: Rusaint.ClassScore) -> String {
        switch classScore {
        case .pass:
            return "P"
        case .failed:
            return "F"
        case .score(let value):
            return "\(value)"
        case .empty:
            return ""
        }
    }
}

/**
 NSSet -> [LectureDetailModel] 변환하는 확장입니다.
 */
public extension Optional where Wrapped == NSSet {
    func toLectureDetailModels() -> [LectureDetailModel]? {
        guard let lectureSet = self as? Set<CDLecture> else { return nil }
        return lectureSet.map { lecture in
            LectureDetailModel(
                code: lecture.code ?? "",
                title: lecture.title ?? "",
                credit: Double(lecture.credit),
                score: lecture.score ?? "",
                grade: Grade(rawValue: lecture.grade ?? "") ?? .unknown,
                professorName: lecture.professorName ?? ""
            )
        }
    }
}
