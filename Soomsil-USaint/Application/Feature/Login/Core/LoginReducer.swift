//
//  LoginReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture
import YDS_SwiftUI

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
        case initResponse(Result<SaintInfo, Error>)
        case loginPressed
        case loginResponse(Result<Void, Error>)
        case deleteResponse(Result<Void, Error>)
    }
    
    @Dependency(\.studentClient) var studentClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.initResponse(Result {
                        return try await studentClient.getSaintInfo()
                    }))
                }
            case .initResponse(.success(let saintInfo)):
                state.id = saintInfo.id
                state.password = saintInfo.password
                return .none
            case .loginPressed:
                state.isLoading = true
                let saintInfo = SaintInfo(id: state.id, password: state.password)
                return .run { send in
                    await send(.loginResponse(Result {
                        try await studentClient.setSaintInfo(saintInfo: saintInfo)
                        try await studentClient.setStudentInfo()
                        // TODO: ReportCard 정보 저장 (saveReportCard(session: session))
                    }))
                }
            case .loginResponse(.success):
                state.isLoading = false
                YDSToast("로그인 성공하였습니다.", haptic: .success)
                return .none
            case .loginResponse(.failure(let error)):
                debugPrint(error)
                return .run { send in
                    await send(.deleteResponse(Result {
                        try await studentClient.deleteStudentInfo()
                    }))
                }
            case .deleteResponse:
                state.isLoading = false
                YDSToast("로그인에 실패하였습니다. 다시 시도해주세요!", duration: .long, haptic: .failed)
                return .none
            default:
                return .none
            }
        }
    }
}

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
