//
//  SemesterListViewModel.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/16/24.
//

import Foundation

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
    
    func getReportList() async -> Result<[GradeSummaryModel], RusaintError>
    func getReportListFromRusaint() async -> Result<[GradeSummaryModel], RusaintError>
}

//final class DefaultSemesterListViewModel: BaseViewModel, SemesterListViewModel {
//    @Published var reportList = [GradeSummaryModel]()
//    @Published var isOnSeasonalSemester = false
//    private let reportCardRepository = ReportCardRepository.shared
//    
//    @MainActor
//    public func getReportList() async -> Result<[GradeSummaryModel], RusaintError> {
//        
//    }
//    
//    @MainActor
//    public func getReportListFromRusaint() async -> Result<[GradeSummaryModel], RusaintError> {
//        
//    }
//}

final class TestReportListViewModel: BaseViewModel, SemesterListViewModel {
    @Published var reportList = [GradeSummaryModel]()
    @Published var isLoading: Bool = false
    @Published var isOnSeasonalSemester: Bool = false
    private let reportCardRepository = ReportCardRepository.shared

    func getReportList() async -> Result<[GradeSummaryModel], RusaintError> {
        return await getReportListFromRusaint()
    }
    func getReportListFromRusaint() async -> Result<[GradeSummaryModel], RusaintError> {
        return .success([
            GradeSummaryModel(
                year: "2022",
                semester: "1 학기",
                credit: 13.5,
                pfCredit: 0.5,
                gpa: 2.22,
                semesterRank: ("12", "34"),
                totalRank: ("34", "566")
            ),
            GradeSummaryModel(
                year: "2022",
                semester: "여름학기",
                credit: 4,
                pfCredit: 0,
                gpa: 2.42,
                semesterRank: ("123", "324"),
                totalRank: ("1", "111")
            ),
            GradeSummaryModel(
                year: "2022",
                semester: "2 학기",
                credit: 12.5,
                pfCredit: 5.5,
                gpa: 2.42,
                semesterRank: ("123", "324"),
                totalRank: ("1", "111")
            ),
            GradeSummaryModel(
                year: "2022",
                semester: "겨울학기",
                credit: 4,
                pfCredit: 0,
                gpa: 3.42,
                semesterRank: ("123", "324"),
                totalRank: ("1", "111")
            ),
            GradeSummaryModel(
                year: "2023",
                semester: "1 학기",
                credit: 19.5,
                pfCredit: 0.5,
                gpa: 4.22,
                semesterRank: ("1", "342"),
                totalRank: ("545", "566")
            )
        ])
    }
}
