//
//  SemesterListViewModel.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/16/24.
//

import SwiftUI
import Rusaint

protocol SemesterListViewModel: BaseViewModel, ObservableObject {
    var reportList: [GradeSummaryModel] { get set }
    var isOnSeasonalSemester: Bool { get set }
    var fetchErrorMessage: String { get set }
    var isLoading: Bool { get set }

    func onAppear() async
    func onRefresh() async
}

final class DefaultSemesterListViewModel: BaseViewModel, SemesterListViewModel {
    
    @Published var reportList = [GradeSummaryModel]()
    @Published var isOnSeasonalSemester = false
    @Published var isLoading = true
    @Published var fetchErrorMessage: String = ""
    
    private let semesterRepository = SemesterRepository.shared
    private var session: USaintSession?
    
    @MainActor
    private func setSession() async -> Result<Void, RusaintError> {
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
    public func getSemesterList() async -> Result<[GradeSummaryModel], RusaintError> {
        let semesterListFromDevice = semesterRepository.getSemesterList()
        if semesterListFromDevice.isEmpty {
            return await getSemesterListFromRusaint()
        }
        return .success(semesterListFromDevice)
    }
    
    @MainActor
    public func getSemesterListFromRusaint() async -> Result<[GradeSummaryModel], RusaintError> {
        do {
            let response = try await CourseGradesApplicationBuilder().build(session: self.session!).semesters(courseType: CourseType.bachelor)
            let rusaintData = response.toGradeSummaryModels()
            return .success(rusaintData)
        } catch {
            return .failure(.applicationError)
        }
    }
    
    /**
     2024년 2학기를 불러오는 함수입니다.
     */
    @MainActor
    public func getCurrentSemesterGrade() async -> Result<GradeSummaryModel, RusaintError> {
        semesterRepository.deleteSemester(year: 2024, semester: "2 학기")
        do {
            let response = try await CourseGradesApplicationBuilder().build(session: self.session!).classes(courseType: .bachelor,
                                                                                                            year: 2024,
                                                                                                            semester: .two,
                                                                                                            includeDetails: false)
            let currentClassesData = response.toLectureDetailModels()
            let currentSemester = GradeSummaryModel(year: 2024,
                                                    semester: "2 학기",
                                                    gpa: 0,
                                                    earnedCredit: 0,
                                                    semesterRank: 0,
                                                    semesterStudentCount: 0,
                                                    overallRank: 0,
                                                    overallStudentCount: 0,
                                                    lectures: currentClassesData)
            return .success(currentSemester)
        } catch {
            return .failure(.applicationError)
        }
    }
    
    private func saveSemesterListToCoreData(_ semesterList: [GradeSummaryModel]) {
        self.semesterRepository.updateSemesterList(semesterList)
    }
    
    private func saveCurrentSemesterToCoreData(_ currentSemester: GradeSummaryModel) {
        self.semesterRepository.addSemester(currentSemester)
    }
    
    /**
     이전학기 [GradeSummaryModel] 을 불러오는 함수입니다.
     - CoreData에 list 존재 시, CoreData 정보를 불러옵니다.
     - CoreData에 list 존재하지 않을 시, Rusaint에서 정보를 불러옵니다.
     */
    @MainActor
    private func loadSemesterListData() async {
        let semesterListResponse = await getSemesterList()
        switch semesterListResponse {
        case .success(let semesterList):
            saveSemesterListToCoreData(semesterList)
        case .failure(let error):
            self.fetchErrorMessage = "\(error)"
        }
    }
    
    /**
     이전학기 [GradeSummaryModel]을 Rusaint에서 불러옵니다.
     */
    @MainActor
    private func loadSemesterListFromRusaint() async {
        let semesterListResponse = await getSemesterListFromRusaint()
        switch semesterListResponse {
        case .success(let semesterList):
            saveSemesterListToCoreData(semesterList)
        case .failure(let error):
            self.fetchErrorMessage = "\(error)"
        }
    }
    
    /**
     현재학기 GradeSummaryModel을 Rusaint에서 불러옵니다.
     */
    @MainActor
    private func loadCurrentSemesterData() async {
        let currentSemesterGradeResponse = await getCurrentSemesterGrade()
        switch currentSemesterGradeResponse {
        case .success(let currentSemester):
            saveCurrentSemesterToCoreData(currentSemester)
        case .failure(let error):
            self.fetchErrorMessage = "\(error)"
        }
    }
    
    @MainActor
    public func onAppear() async {
        let sessionResult = await setSession()
        
        switch sessionResult {
        case .success:
            // 이전학기 호출 (CoreData -> Rusaint)
            await loadSemesterListData()
            // 현재학기 호출 (Rusaint)
            await loadCurrentSemesterData()
            
            reportList = semesterRepository.getSemesterList()
        case .failure(let error):
            self.fetchErrorMessage = "\(error)"
        }
        isLoading = false
    }
    
    @MainActor
    public func onRefresh() async {
        let sessionResult = await setSession()
        semesterRepository.deleteSemesterList()
        
        switch sessionResult {
        case .success:
            // 이전학기 호출 (Rusaint)
            await loadSemesterListFromRusaint()
            // 현재학기 호출 (Rusaint)
            await loadCurrentSemesterData()
            
            reportList = semesterRepository.getSemesterList()
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
