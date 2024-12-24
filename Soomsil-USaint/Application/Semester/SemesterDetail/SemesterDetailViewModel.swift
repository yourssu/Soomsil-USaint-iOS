//
//  SemesterDetailViewModel.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/18/24.
//

import Foundation
import Rusaint

public protocol SemesterDetailViewModel: BaseViewModel, ObservableObject {

    var gradeSummary: GradeSummaryModel { get set }
    var rowAnimation: Bool { get set }

    var isCapturing: Bool { get set }
    var showConfirmDialog: Bool { get set }
    var showSuccessAlert: Bool { get set }
    var showFailureAlert: Bool { get set }
    var masking: Bool { get set }

    func getSemesterDetailFromRusaint() async -> Result<[LectureDetailModel], RusaintError>

    func calculateGPA() -> Double

    func takeScreenshot()
    func takeScreenshotWithMasking(screenshotMethod: @escaping () -> Void)
    func takeScreenshotWithoutMasking(screenshotMethod: @escaping () -> Void)
    func takeScreenshotSuccess()
    func takeScreenshotFailure()
}

// MARK: - Default func
public extension SemesterDetailViewModel {
    func calculateGPA() -> Double {
        let lectures = self.gradeSummary.lectures
        var gradeSum: Double = 0.0
        var creditSum: Double = 0.0
        
        let nonNilLectures = lectures.compactMap { $0 }
        
        let validLectures = nonNilLectures.filter { lecture in
            lecture.grade != .pass &&
            lecture.grade != .fail &&
            lecture.grade != .unknown &&
            lecture.grade != .empty
        }
        
        validLectures.forEach { lecture in
            let gpa: Double = lecture.grade.gpa
            if gpa > 0.0 {
                gradeSum += lecture.credit * gpa
                creditSum += lecture.credit
            }
        }
        guard creditSum > 0 else { return 0.0 }
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

final class DefaultSemesterDetailViewModel: BaseViewModel, SemesterDetailViewModel {

    @Published var rowAnimation: Bool = false
    @Published var isCapturing: Bool = false
    @Published var showConfirmDialog: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showFailureAlert: Bool = false
    @Published var masking: Bool = false
    
    @Published var gradeSummary: GradeSummaryModel
    private let semesterRepository = SemesterRepository.shared
    private var session: USaintSession?

    init(gradeSummary: GradeSummaryModel) {
        self.gradeSummary = gradeSummary
    }
    
    @MainActor
    public func getSemesterDetailFromRusaint() async -> Result<[LectureDetailModel], RusaintError> {
        let userInfo = semesterRepository.getUserLoginInformation()
        do {
            self.session = try await USaintSessionBuilder().withPassword(id: userInfo[0], password: userInfo[1])
            if self.session != nil {
                let lectureDetailFromRusaint = try await CourseGradesApplicationBuilder().build(session: self.session!)
                    .classes(courseType: .bachelor,
                             year: UInt32(self.gradeSummary.year),
                             semester: semesterType(self.gradeSummary.semester),
                             includeDetails: false)
                
//                print("\(lectureDetailFromRusaint)")
                gradeSummary.lectures = lectureDetailFromRusaint.toLectureDetailModels()
                return .success(gradeSummary.lectures)
            } else {
                return .failure(RusaintError.invalidClientError)
            }
        } catch (let error) {
            return .failure(error as! RusaintError)
        }
    }
    
    // FIXME: - 함수 이동 필요
    func semesterType(_ string: String) -> SemesterType {
        switch string.trimmingCharacters(in: .whitespacesAndNewlines) {
        case "1 학기", "1학기":
            return .one
        case "여름학기":
            return .summer
        case "2 학기", "2학기":
            return .two
        case "겨울학기":
            return .winter
        default:
            return .winter
        }
    }

//    @MainActor
//    func getSingleReport() async -> Result<ReportDetailModel, ParsingError> {
//        let reportFromDevice = semesterRepository.getLectureDetail(report.year, report.semester)
//        if let reportFromDevice {
//            return .success(reportFromDevice)
//        }
//        return await getSingleReportFromSN()
//    }
//
//    @MainActor
//    func getSingleReportFromSN() async -> Result<ReportDetailModel, ParsingError> {
//        semesterRepository.setYearAndSemester(report.year, report.semester)
//        do {
//            let response = try await SaintNexus.shared.loadSingleReport()
//            if response.status == 200, let rdata = response.rdata {
//                self.semesterRepository.updateReportDetail(rdata)
//                guard let detail = self.semesterRepository.getLectureDetail(
//                    report.year,
//                    report.semester
//                ) else {
//                    throw ParsingError.error("파싱 데이터 에러")
//                }
//                return .success(detail)
//            } else {
//                throw ParsingError.error("\(response.status) 에러")
//            }
//        } catch is SNError {
//            return .failure(.error("Saint Nexus 클라이언트 에러"))
//        } catch ParsingError.error(let error) {
//            return .failure(.error(error))
//        } catch {
//            return .failure(.error(error.localizedDescription))
//        }
//    }
}

//final class TestSemesterDetailViewModel: BaseViewModel, SemesterDetailViewModel {
//    func calculateGPA() -> Double {
//        return 0.0
//    }
//    
//    @Published var report: GradeSummaryModel
//    @Published var reportDetail: LectureDetailModel?
//    @Published var rowAnimation: Bool = false
//    @Published var isCapturing: Bool = false
//    @Published var showConfirmDialog: Bool = false
//    @Published var showSuccessAlert: Bool = false
//    @Published var showFailureAlert: Bool = false
//    @Published var masking: Bool = false
//    override init() {
//        self.report = GradeSummaryModel(
//            year: 2024,
//            semester: "2 학기",
//            gpa: 21.0,
//            earnedCredit: 23.0,
//            semesterRank: 50,
//            semesterStudentCount: 70,
//            overallRank: 100,
//            overallStudentCount: 148,
//            lectures: [LectureDetailModel(code: "", title: "", credit: 0.0, score: "", grade: .aMinus, professorName: "")]
//        )
//        super.init()
//    }
//    func getSingleReport() async -> Result<LectureDetailModel, ParsingError> { return .failure(.error("test")) }
//    func getSingleReportFromSN() async -> Result<LectureDetailModel, ParsingError> { return .failure(.error("test")) }
//}
