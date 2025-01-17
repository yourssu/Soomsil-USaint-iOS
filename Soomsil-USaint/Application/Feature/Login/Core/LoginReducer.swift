//
//  LoginReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct LoginReducer {
    @ObservableState
    struct State {
        var isLoading = false
        var id = ""
        var password = ""
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case loginPressed
        case loginResponse(Result<Void, Error>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .loginPressed:
                state.isLoading = true
                return .run { send in
                    await send(.loginResponse(Result {
                        try await Task.sleep(for: .seconds(1))
                    }))
                }
            case .loginResponse:
                state.isLoading = false
                return .none
            default:
                return .none
            }
        }
    }
}
// 1. Button Action
//                    Task {
//                        isLoading = true
//                        do {
//                            self.session =  try await USaintSessionBuilder().withPassword(id: id, password: password)
//                            if self.session != nil {
//
//                                await saveUserInfo(id: id, password: password, session: session!)
//                                await saveReportCard(session: session!)
//
//                                isLoggedIn = true
//                                isLoading = false
//                                YDSToast("로그인 성공하였습니다.", haptic: .success)
//
//                            } else {
//                                YDSToast("로그인에 실패하였습니다. 다시 시도해주세요!", duration: .long, haptic: .failed)
//                                HomeRepository.shared.deleteAllData()
//                            }
//                        } catch {
//                            isLoading = false
//
//                            YDSToast("로그인에 실패하였습니다. 다시 시도해주세요!", duration: .long, haptic: .failed)
//                            HomeRepository.shared.deleteAllData()
//                        }
//                    }

//    private func initial() {
//        let info = HomeRepository.shared.getUserInformation()
//        switch info {
//        case .success(let success):
//            self.id = success.id
//            self.password = success.password
//        case .failure:
//            self.id = ""
//            self.password = ""
//        }
//    }
//
//    private func saveUserInfo(id: String, password: String, session: USaintSession) async {
//        HomeRepository.shared.updateUserInformation(id: id, password: password)
//
//        do {
//            let personalInfo = try await StudentInformationApplicationBuilder().build(session: self.session!).general()
//            let name = personalInfo.name.replacingOccurrences(of: " ", with: "")
//            let major = personalInfo.department
//            let schoolYear = "\(personalInfo.grade)학년"
//            HomeRepository.shared.updateUserInformation(name: name,
//                                                        major: major,
//                                                        schoolYear: schoolYear)
//        } catch {
//            print("Failed to save userInfo: \(error)")
//        }
//    }

//    private func saveReportCard(session: USaintSession) async {
//        do {
//            let courseGrades = try await CourseGradesApplicationBuilder().build(session: self.session!).certificatedSummary(courseType: .bachelor)
//            let graduationRequirement = try await GraduationRequirementsApplicationBuilder().build(session: self.session!).requirements()
//            let requirements = graduationRequirement.requirements.filter { $0.value.name.hasPrefix("학부-졸업학점") }
//                .compactMap { $0.value.requirement ?? 0}
//
//            if let graduateCredit = requirements.first {
//                HomeRepository.shared.updateTotalReportCard(gpa: courseGrades.gradePointsAvarage, earnedCredit: courseGrades.earnedCredits, graduateCredit: Float(graduateCredit))
//            }
//
//        } catch {
//            print("Failed to save reportCard: \(error)")
//        }
//    }
