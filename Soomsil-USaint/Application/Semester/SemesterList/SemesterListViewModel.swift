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
    var fetchErrorMessage: String { get set }
    var isLoading: Bool { get set }

    func getSemesterList() async -> Result<[GradeSummaryModel], RusaintError>
    func getSemesterListFromRusaint() async -> Result<[GradeSummaryModel], RusaintError>
    func getCurrentSemesterGrade() async -> Result<[LectureDetailModel], RusaintError>
    func onAppear() async
}

final class DefaultSemesterListViewModel: BaseViewModel, SemesterListViewModel {
    
    @Published var reportList = [GradeSummaryModel]()
    @Published var isOnSeasonalSemester = false
    @Published var isLoading = true
    @Published var fetchErrorMessage: String = ""
    
    private let semesterRepository = SemesterRepository.shared
    private var session: USaintSession?
    
    @MainActor
    public func getSemesterList() async -> Result<[GradeSummaryModel], RusaintError> {
        //        reportCardRepository.deleteSemesterList()
        let userInfo = semesterRepository.getUserLoginInformation()
        do {
            self.session =  try await USaintSessionBuilder().withPassword(id: userInfo[0], password: userInfo[1])
            if self.session != nil {
                let gradeSummaryFromDevice = semesterRepository.getSemesterList()
                if !gradeSummaryFromDevice.isEmpty {
                    return .success(gradeSummaryFromDevice)
                }
                return await getSemesterListFromRusaint()
            } else {
                return .failure(RusaintError.invalidClientError)
            }
        } catch {
            print("=== \(error)")
            return .failure(error as! RusaintError)
        }
    }
    
    @MainActor
    public func setSession() async -> Result<Void, RusaintError> {
        let userInfo = semesterRepository.getUserLoginInformation()
        do {
            self.session = try await USaintSessionBuilder().withPassword(id: userInfo[0], password: userInfo[1])
            
            guard self.session != nil else {
                return .failure(.invalidClientError)
            }
            return .success(())
            
        } catch {
            return .failure(.invalidClientError)
        }
    }
    
    @MainActor
    public func getSemesterListFromRusaint() async -> Result<[GradeSummaryModel], RusaintError> {
        do {
            let response = try await CourseGradesApplicationBuilder().build(session: self.session!).semesters(courseType: CourseType.bachelor)
            let rusaintData = response.toGradeSummaryModels()
            
            self.semesterRepository.updateSemesterList(rusaintData)
            let list = self.semesterRepository.getSemesterList()
            
            if list.isEmpty {
                throw ParsingError.error("데이터 에러")
            } else {
                return .success(list)
            }
            
        } catch {
            return .failure(.applicationError)
        }
    }
    
    /**
     2024년 2학기를 불러오는 함수입니다.
     */
    @MainActor
    public func getCurrentSemesterGrade() async -> Result<[LectureDetailModel], RusaintError> {
        do {
            let response = try await CourseGradesApplicationBuilder().build(session: self.session!).classes(courseType: .bachelor,
                                                                                                            year: 2024,
                                                                                                            semester: .two,
                                                                                                            includeDetails: false)
            let rusaintData = response.toLectureDetailModels()
            return .success(rusaintData)
        } catch {
            return .failure(.applicationError)
        }
    }

    @MainActor
    public func onAppear() async {
        let sessionResult = await setSession()
        
        switch sessionResult {
        case .success:
            var semesterListResult = [GradeSummaryModel]()
            let currentGrade = await getCurrentSemesterGrade()
            switch currentGrade {
            case .success(let response):
                if !response.isEmpty {
                    semesterListResult.append(GradeSummaryModel(year: 2024, semester: "2 학기"))
                }
                let listResponse = await getSemesterListFromRusaint()
                switch listResponse {
                case .success(let response):
                    semesterListResult.append(contentsOf: response)
                case .failure(let error):
                    self.fetchErrorMessage = "\(error)"
                }
                reportList = semesterListResult
            case .failure(let error):
                self.fetchErrorMessage = "\(error)"
            }
        case .failure(let error):
            self.fetchErrorMessage = "\(error)"
        }
        isLoading = false
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
