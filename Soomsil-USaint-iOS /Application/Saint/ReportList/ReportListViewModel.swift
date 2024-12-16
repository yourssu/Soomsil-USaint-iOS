//
//  ReportListViewModel.swift
//  Soomsil
//
//  Created by 정종인 on 2023/06/01.
//  Copyright © 2023 Yourssu. All rights reserved.
//

import Foundation
import SaintNexus
import Combine

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

protocol ReportListViewModel: BaseViewModel, ObservableObject {
    var reportList: [ReportSummaryModel] { get set }
    var isOnSeasonalSemester: Bool { get set }

    func getReportList() async -> Result<[ReportSummaryModel], ParsingError>
    func getReportListFromSN() async -> Result<[ReportSummaryModel], ParsingError>
}

final class DefaultReportListViewModel: BaseViewModel, ReportListViewModel {
    @Published var reportList = [ReportSummaryModel]()
    @Published var isOnSeasonalSemester = false
    private let saintRepository = SaintRepository.shared

    @MainActor
    func getReportList() async -> Result<[ReportSummaryModel], ParsingError> {
        let summaryFromDevice = saintRepository.getReportSummaryList()
        if !summaryFromDevice.isEmpty {
            return .success(summaryFromDevice)
        }
        return await getReportListFromSN()
    }

    @MainActor
    func getReportListFromSN() async -> Result<[ReportSummaryModel], ParsingError> {
        do {
            let response = try await SaintNexus.shared.loadReports()
            if response.status == 200, let rdata = response.rdata {
                self.saintRepository.updateReportSummary(rdata)
                let list = self.saintRepository.getReportSummaryList()
                if list.isEmpty {
                    throw ParsingError.error("데이터 에러")
                } else {
                    return .success(list)
                }
            } else {
                throw ParsingError.error("\(response.status) 에러")
            }
        } catch is SNError {
            return .failure(.error("Saint Nexus 클라이언트 에러"))
        } catch ParsingError.error(let error) {
            return .failure(.error(error))
        } catch {
            return .failure(.error(error.localizedDescription))
        }
    }
}

final class TestReportListViewModel: BaseViewModel, ReportListViewModel {
    @Published var reportList = [ReportSummaryModel]()
    @Published var isLoading: Bool = false
    @Published var isOnSeasonalSemester: Bool = false
    private let saintRepository = SaintRepository.shared

    func getReportList() async -> Result<[ReportSummaryModel], ParsingError> { return .success([]) }
    func getReportListFromSN() async -> Result<[ReportSummaryModel], ParsingError> {
        return .success([
            ReportSummaryModel(
                year: "2022",
                semester: "1 학기",
                credit: 13.5,
                pfCredit: 0.5,
                semesterGPA: 2.22,
                semesterRank: ("12", "34"),
                totalRank: ("34", "566")
            ),
            ReportSummaryModel(
                year: "2022",
                semester: "여름학기",
                credit: 4,
                pfCredit: 0,
                semesterGPA: 2.42,
                semesterRank: ("123", "324"),
                totalRank: ("1", "111")
            ),
            ReportSummaryModel(
                year: "2022",
                semester: "2 학기",
                credit: 12.5,
                pfCredit: 5.5,
                semesterGPA: 2.42,
                semesterRank: ("123", "324"),
                totalRank: ("1", "111")
            ),
            ReportSummaryModel(
                year: "2022",
                semester: "겨울학기",
                credit: 4,
                pfCredit: 0,
                semesterGPA: 3.42,
                semesterRank: ("123", "324"),
                totalRank: ("1", "111")
            ),
            ReportSummaryModel(
                year: "2023",
                semester: "1 학기",
                credit: 19.5,
                pfCredit: 0.5,
                semesterGPA: 4.22,
                semesterRank: ("1", "342"),
                totalRank: ("545", "566")
            )
        ])
    }
}
