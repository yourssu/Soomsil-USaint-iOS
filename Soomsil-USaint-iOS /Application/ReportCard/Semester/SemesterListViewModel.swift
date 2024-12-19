//
//  SemesterListViewModel.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/16/24.
//

import SwiftUI
import Rusaint

extension StringProtocol {
    var tupleOfSplittedString: (String, String) {
        if !self.isEmpty {
            let splitted = self.split(separator: "/").map { String($0) }
            let firstPart = splitted[0].replacingOccurrences(of: " ", with: "")
            let otherPart = String(splitted[1...].joined()).replacingOccurrences(of: " ", with: "")
            return (firstPart, otherPart)
        }
        return ("", "")
    }
}

protocol SemesterListViewModel: BaseViewModel, ObservableObject {
    var reportList: [GradeSummaryModel] { get set }
    var isOnSeasonalSemester: Bool { get set }
    
    // FIXME: - session 인자 제거
    func getSemesterList(session: USaintSession?) async -> Result<[GradeSummaryModel], RusaintError>
    func getSemesterListFromRusaint(session: USaintSession) async -> Result<[GradeSummaryModel], RusaintError>
}

final class DefaultSemesterListViewModel: BaseViewModel, SemesterListViewModel {
    @Published var reportList = [GradeSummaryModel]()
    @Published var isOnSeasonalSemester = false
    private let reportCardRepository = ReportCardRepository.shared
    
    @MainActor
    public func getSemesterList(session: USaintSession?) async -> Result<[GradeSummaryModel], RusaintError> {
        reportCardRepository.deleteSemesterList()
        let gradeSummaryFromDevice = reportCardRepository.getSemesterList()
        if !gradeSummaryFromDevice.isEmpty {
            print("🏳️‍🌈coredata: \(gradeSummaryFromDevice)")
            return .success(gradeSummaryFromDevice)
        }
        return await getSemesterListFromRusaint(session: session!)
    }
    
    @MainActor
    public func getSemesterListFromRusaint(session: USaintSession) async -> Result<[GradeSummaryModel], RusaintError> {
        do {
            let response = try await CourseGradesApplicationBuilder().build(session: session).semesters(courseType: CourseType.bachelor)
            let rusaintData = response.toGradeSummaryModels()

            self.reportCardRepository.updateSemesterList(rusaintData)
            let list = self.reportCardRepository.getSemesterList()
            if list.isEmpty {
                throw ParsingError.error("데이터 에러")
            } else {
                print("🏳️‍🌈Rusaint: \(list)")
                return .success(list)
            }

            
        } catch (let error) {
            return .failure(error as! RusaintError)
        }
    }

}

//final class TestSemesterListViewModel: BaseViewModel, SemesterListViewModel {
//    @Published var reportList = [GradeSummaryModel]()
//    @Published var isLoading: Bool = false
//    @Published var isOnSeasonalSemester: Bool = false
//    private let reportCardRepository = ReportCardRepository.shared
//
//    func getSemesterList() async -> Result<[GradeSummaryModel], RusaintError> {
//        return await getSemesterListFromRusaint()
//    }
//    func getSemesterListFromRusaint() async -> Result<[GradeSummaryModel], RusaintError> {
//        return .success([
//            GradeSummaryModel(
//                year: 2022,
//                semester: "1 학기",
//                gpa: 2.22,
//                earnedCredit: 13.5,
//                semesterRank: 12,
//                semesterStudentCount: 34,
//                overallRank: 100,
//                overallStudentCount: 566
//            ),
//            GradeSummaryModel(
//                year: 2022,
//                semester: "여름학기",
//                gpa: 3.22,
//                earnedCredit: 13.5,
//                semesterRank: 123,
//                semesterStudentCount: 111,
//                overallRank: 1,
//                overallStudentCount: 324
//            ),
//            GradeSummaryModel(
//                year: 2022,
//                semester: "2 학기",
//                gpa: 4.42,
//                earnedCredit: 4.0,
//                semesterRank: 123,
//                semesterStudentCount: 100,
//                overallRank: 11,
//                overallStudentCount: 324
//            ),
//            GradeSummaryModel(
//                year: 2022,
//                semester: "겨울학기",
//                gpa: 1.92,
//                earnedCredit: 4.0,
//                semesterRank: 123,
//                semesterStudentCount: 324,
//                overallRank: 1,
//                overallStudentCount: 161
//            ),
//            GradeSummaryModel(
//                year: 2023,
//                semester: "1 학기",
//                gpa: 3.50,
//                earnedCredit: 19.5,
//                semesterRank: 11,
//                semesterStudentCount: 342,
//                overallRank: 545,
//                overallStudentCount: 586
//            )
//        ])
//    }
//}
