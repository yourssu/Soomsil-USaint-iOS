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
    var isLatestSemesterNotYetConfirmed: Bool { get }

    func onAppear() async
    func onRefresh() async
}

final class DefaultSemesterListViewModel: BaseViewModel, SemesterListViewModel {
    @Published var reportList = [GradeSummaryModel]()
    @Published var isOnSeasonalSemester = false
    @Published var isLoading = true
    @Published var fetchErrorMessage: String = ""

    @Published var isLatestSemesterExistInList: Bool = false
    @Published var isLatestSemesterExistInCurrentSemester: Bool = false
    var isLatestSemesterNotYetConfirmed: Bool {
        !isLatestSemesterExistInList && isLatestSemesterExistInCurrentSemester
    }

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
            saveSemesterListToCoreData(rusaintData)
            return .success(rusaintData)
        } catch {
            return .failure(.applicationError)
        }
    }
    
    /**
     2024년 2학기를 불러오는 함수입니다.
     */
    @MainActor
    private func getCurrentSemesterGrade() async -> Result<GradeSummaryModel?, RusaintError> {
        semesterRepository.deleteSemester(year: 2024, semester: "2 학기")
        do {
            let response = try await CourseGradesApplicationBuilder().build(session: self.session!).classes(courseType: .bachelor,
                                                                                                            year: 2024,
                                                                                                            semester: .two,
                                                                                                            includeDetails: false)
            if response.isEmpty {
                return .success(nil)
            }
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
        case .success(_): break
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

            if let (currentYear, currentSemester) = SemesterUtility.shared.currentYearAndSemester(),
               semesterList.contains(where: { $0.year == currentYear && $0.semester == currentSemester }) {
                self.isLatestSemesterExistInList = true
            }
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
        case .success(let currentSemesterGrade):
            if let currentSemesterGrade = currentSemesterGrade {
                saveCurrentSemesterToCoreData(currentSemesterGrade)
                if let (currentYear, currentSemester) = SemesterUtility.shared.currentYearAndSemester(),
                   currentSemesterGrade.year == currentYear,
                   currentSemesterGrade.semester == currentSemester {
                    self.isLatestSemesterExistInCurrentSemester = true
                }
            }
            
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

final class MockSemesterListViewModel: BaseViewModel, SemesterListViewModel {
    
    @Published var reportList = [GradeSummaryModel]()
    @Published var isOnSeasonalSemester = false
    @Published var isLoading = true
    @Published var fetchErrorMessage: String = ""
    @Published var isLatestSemesterNotYetConfirmed: Bool = false

    public func getSemesterList() async -> Result<[GradeSummaryModel]?, RusaintError> {
        return await getSemesterListFromRusaint()
    }

    public func setSession() async -> Result<Void, RusaintError> {
        return .success(())
    }

    public func getSemesterListFromRusaint() async -> Result<[GradeSummaryModel]?, RusaintError> {
        .success([
            .init(year: 2024, semester: "1 학기", gpa: 4.1, earnedCredit: 17.5, semesterRank: 3, semesterStudentCount: 30, overallRank: 4, overallStudentCount: 33, lectures: []),
            .init(year: 2023, semester: "2 학기", gpa: 1.9, earnedCredit: 17.5, semesterRank: 3, semesterStudentCount: 30, overallRank: 4, overallStudentCount: 33, lectures: []),
            .init(year: 2023, semester: "1 학기", gpa: 4.4, earnedCredit: 17.5, semesterRank: 3, semesterStudentCount: 30, overallRank: 4, overallStudentCount: 33, lectures: []),
        ])
    }

    /**
     2024년 2학기를 불러오는 함수입니다.
     */
    func getCurrentSemesterGrade() async -> Result<GradeSummaryModel, RusaintError> {
        return .success(
            GradeSummaryModel(year: 2024,
                              semester: "2학기",
                              gpa: 2.5,
                              earnedCredit: 18,
                              semesterRank: 4,
                              semesterStudentCount: 40,
                              overallRank: 2,
                              overallStudentCount: 60,
                              lectures: [
                                .init(code: "code1", title: "과목명1", credit: 3.0, score: "score1", grade: .aMinus, professorName: "교수명1"),
                                .init(code: "code2", title: "과목명2", credit: 2.0, score: "score2", grade: .bPlus, professorName: "교수명2"),
                                .init(code: "code3", title: "과목명3", credit: 3.0, score: "score3", grade: .unknown, professorName: "교수명3"),
                              ]
                             )
        )
    }

    public func onAppear() async {
        let sessionResult = await setSession()

        switch sessionResult {
        case .success:
            var semesterListResult = [GradeSummaryModel]()
            let listResponse = await getSemesterListFromRusaint()
            switch listResponse {
            case .success(let response):
                semesterListResult.append(contentsOf: response!)
            case .failure(let error):
                self.fetchErrorMessage = "\(error)"
            }

            let currentGrade = await getCurrentSemesterGrade()
            switch currentGrade {
            case .success(let response):
                if let _ = response.lectures {
                    // 만약 최근 학기가 List에 포함이 되어있지 않다면? 성적 처리중인 친구.
                    if let (currentYear, currentSemester) = SemesterUtility.shared.currentYearAndSemester(),
                       !semesterListResult.contains(where: { $0.year == currentYear && $0.semester == currentSemester }) {
                        self.isLatestSemesterNotYetConfirmed = true
                        semesterListResult.insert(GradeSummaryModel(year: currentYear, semester: currentSemester), at: 0)
                    }
                }
//                if !response.lectures.isEmpty {
//                    
//                }
            case .failure(let error):
                self.fetchErrorMessage = "\(error)"
            }
            self.reportList = semesterListResult
        case .failure(let error):
            self.fetchErrorMessage = "\(error)"
        }
        isLoading = false
    }

    public func onRefresh() async {

    }
}
