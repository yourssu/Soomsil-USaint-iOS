//
//  ReportDetailViewModel.swift
//  Soomsil
//
//  Created by 정종인 on 2023/06/02.
//  Copyright © 2023 Yourssu. All rights reserved.
//

import Foundation
import SaintNexus

public protocol ReportDetailViewModel: BaseViewModel, ObservableObject {

    var report: ReportSummaryModel { get set }
    var reportDetail: ReportDetailModel? { get set }

    var rowAnimation: Bool { get set }

    var isCapturing: Bool { get set }
    var showConfirmDialog: Bool { get set }
    var showSuccessAlert: Bool { get set }
    var showFailureAlert: Bool { get set }
    var masking: Bool { get set }

    func getSingleReport() async -> Result<ReportDetailModel, ParsingError>
    func getSingleReportFromSN() async -> Result<ReportDetailModel, ParsingError>

    func calculateGPA() -> Double

    func takeScreenshot()
    func takeScreenshotWithMasking(screenshotMethod: @escaping () -> Void)
    func takeScreenshotWithoutMasking(screenshotMethod: @escaping () -> Void)
    func takeScreenshotSuccess()
    func takeScreenshotFailure()
}

// MARK: - Default func
public extension ReportDetailViewModel {
    func calculateGPA() -> Double {
        guard let lectures = self.reportDetail?.lectures else { return 0.0 }
        var gradeSum: Double = 0.0
        var creditSum: Double = 0.0
        lectures
            .compactMap { $0 }
            .filter { lecture in
                lecture.grade != .pass && lecture.grade != .fail && lecture.grade != .unknown
            }
            .forEach { lecture in
                let gpa: Double = lecture.grade.gpa
                if gpa > 0.0 {
                    gradeSum += lecture.credit * gpa
                    creditSum += lecture.credit
                }
            }
        return floor(10000 * (gradeSum * 10) / (creditSum * 10)) / 10000
    }

    func takeScreenshot() {
        showConfirmDialog = true
    }
    func takeScreenshotWithMasking(screenshotMethod: @escaping () -> Void) {
        masking = true
        isCapturing = true
        defer {
            masking = false
            isCapturing = false
        }
        screenshotMethod()
    }
    func takeScreenshotWithoutMasking(screenshotMethod: @escaping () -> Void) {
        isCapturing = true
        defer {
            isCapturing = false
        }
        screenshotMethod()
    }
    func takeScreenshotSuccess() {
        showSuccessAlert = true
    }
    func takeScreenshotFailure() {
        showFailureAlert = true
    }
}

final class DefaultReportDetailViewModel: BaseViewModel, ReportDetailViewModel {
    @Published var report: ReportSummaryModel
    @Published var reportDetail: ReportDetailModel?
    @Published var rowAnimation: Bool = false
    @Published var isCapturing: Bool = false
    @Published var showConfirmDialog: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showFailureAlert: Bool = false
    @Published var masking: Bool = false
    private let saintRepository = SaintRepository.shared
    init(report: ReportSummaryModel) {
        self.report = report
    }

    @MainActor
    func getSingleReport() async -> Result<ReportDetailModel, ParsingError> {
        let reportFromDevice = saintRepository.getReportDetail(report.year, report.semester)
        if let reportFromDevice {
            return .success(reportFromDevice)
        }
        return await getSingleReportFromSN()
    }

    @MainActor
    func getSingleReportFromSN() async -> Result<ReportDetailModel, ParsingError> {
        saintRepository.setYearAndSemester(report.year, report.semester)
        do {
            let response = try await SaintNexus.shared.loadSingleReport()
            if response.status == 200, let rdata = response.rdata {
                self.saintRepository.updateReportDetail(rdata)
                guard let detail = self.saintRepository.getReportDetail(
                    report.year,
                    report.semester
                ) else {
                    throw ParsingError.error("파싱 데이터 에러")
                }
                return .success(detail)
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

final class TestReportDetailViewModel: BaseViewModel, ReportDetailViewModel {
    @Published var report: ReportSummaryModel
    @Published var reportDetail: ReportDetailModel?
    @Published var rowAnimation: Bool = false
    @Published var isCapturing: Bool = false
    @Published var showConfirmDialog: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showFailureAlert: Bool = false
    @Published var masking: Bool = false
    override init() {
        self.report = ReportSummaryModel(
            year: "2024",
            semester: "1 학기",
            credit: 17.0,
            pfCredit: 0.5,
            semesterGPA: 3.28,
            semesterRank: ("44", "135"),
            totalRank: ("38", "137")
        )
        super.init()
    }
    func getSingleReport() async -> Result<ReportDetailModel, ParsingError> { return .failure(.error("test")) }
    func getSingleReportFromSN() async -> Result<ReportDetailModel, ParsingError> { return .failure(.error("test")) }
}
