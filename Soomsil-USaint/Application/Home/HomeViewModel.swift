//
//  HomeViewModel.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/16/24.
//

import SwiftUI
import Rusaint

protocol HomeViewModel: ObservableObject {
    var person: PersonalInfo? { get set }
    var fetchErrorMessage: String { get set }
    func isLogedIn() -> Bool
    func hasCachedUserInformation() -> Bool
    func syncCachedUserInformation()
    func getCachedUserInformation() -> PersonalInfo?
    func hasFeature(_ item: HomeItem) -> Bool
    func loadCurrentSemesterData() async -> GradeSummaryModel
}

final class DefaultSaintHomeViewModel: HomeViewModel {
    @Published var person: PersonalInfo?
    @Published var fetchErrorMessage: String = ""
    private var session: USaintSession?
    private let homeRepository = HomeRepository.shared

    func isLogedIn() -> Bool {
        return self.person != nil
    }
    func hasCachedUserInformation() -> Bool {
        homeRepository.hasCachedUserInformation
    }
    func syncCachedUserInformation() {
        self.person = getCachedUserInformation()
    }
    func getCachedUserInformation() -> PersonalInfo? {
        let userInfo = homeRepository.getUserInformation() 
        switch userInfo {
        case let .success(info):
            return PersonalInfo(name: info.name, major: info.major, schoolYear: info.schoolYear)
        case .failure:
            break
        }
        return nil
    }
    func hasFeature(_ item: HomeItem) -> Bool {
        switch item {
        case .grade:
            true
        case .chapel:
            true
        case .graduation:
            true
        }
    }
    
    // MARK: session
    
    @MainActor
    private func setSession() async -> Result<Void, RusaintError> {
        let userInfo = SemesterRepository.shared.getUserLoginInformation()
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
    
    // MARK: current semester
    /**
     2024년 2학기를 불러오는 함수입니다.
     */
    @MainActor
    private func getCurrentSemesterGrade() async -> Result<GradeSummaryModel?, RusaintError> {
        SemesterRepository.shared.deleteSemester(year: 2024, semester: "2 학기")
        let userInfo = SemesterRepository.shared.getUserLoginInformation()
        do {
            self.session = try await USaintSessionBuilder().withPassword(id: userInfo[0], password: userInfo[1])
            if self.session != nil {
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
        } catch {
            return .failure(.applicationError)
        }
        return .failure(.applicationError)
    }
    
    private func saveCurrentSemesterToCoreData(_ currentSemester: GradeSummaryModel) {
        SemesterRepository.shared.addSemester(currentSemester)
    }
    
    /**
     현재학기 GradeSummaryModel을 Rusaint에서 불러옵니다.
     */
    @MainActor
    public func loadCurrentSemesterData() async -> GradeSummaryModel {
        let currentSemesterGradeResponse = await getCurrentSemesterGrade()
        switch currentSemesterGradeResponse {
        case .success(let currentSemesterGrade):
            if let currentSemesterGrade = currentSemesterGrade {
                saveCurrentSemesterToCoreData(currentSemesterGrade)
                return currentSemesterGrade
            }
            
        case .failure(let error):
            self.fetchErrorMessage = "\(error)"
        }
        return GradeSummaryModel(year: 0, semester: "0 학기")
    }
    
}

final class TestSaintMainHomeViewModel: HomeViewModel {
    func loadCurrentSemesterData() async -> GradeSummaryModel {
        return GradeSummaryModel(year: 2024, semester: "2 학기")
    }
    
    var fetchErrorMessage: String = ""
    
    @Published var person: PersonalInfo?
    
    func isLogedIn() -> Bool {
        return self.person != nil
    }
    func hasCachedUserInformation() -> Bool {
        true
    }
    func syncCachedUserInformation() {
        self.person = getCachedUserInformation()
    }
    func getCachedUserInformation() -> PersonalInfo? {
        PersonalInfo(name: "이조은", major: "글로벌미디어학부", schoolYear: "24")
    }
    func hasFeature(_ item: HomeItem) -> Bool {
        switch item {
        case .grade:
            true
        case .chapel:
            true
        case .graduation:
            true
        }
    }
}
