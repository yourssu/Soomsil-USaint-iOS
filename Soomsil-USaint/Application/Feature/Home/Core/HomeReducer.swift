//
//  HomeReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct HomeReducer {
    @ObservableState
    struct State {
        @Shared(.appStorage("isFirst")) var isFirst = true
        @Shared(.appStorage("permission")) var permission = false

        var studentInfo: StudentInfo = StudentInfo(name: "", major: "", schoolYear: "")
        var totalReportCard: TotalReportCard = TotalReportCard(gpa: 0.0, earnedCredit: 0.0, graduateCredit: 0.0)
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case initStudentReponse(Result<StudentInfo, Error>)
        case initTotalReportCardResponse(Result<TotalReportCard, Error>)
        case checkPushAuthorizationResponse(Result<Bool, Error>)
        case sendTestPushResponse(Result<Void, Error>)
        case settingPressed
        case semesterListPressed
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    @Dependency(\.studentClient) var studentClient
    @Dependency(\.gradeClient) var gradeClient


    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                let isFirst = state.isFirst
                debugPrint("Home - Before: \(state.isFirst)")
                state.$isFirst.withLock { $0 = false }
                debugPrint("Home - After: \(state.isFirst)")
                return .run { send in
                    await send(.checkPushAuthorizationResponse(Result {
                        if (isFirst) {
                            return try await localNotificationClient.requestPushAuthorization()
                        } else {
                            return try await localNotificationClient.getPushAuthorizationStatus()
                        }
                    }))
                    await send(.initStudentReponse(Result {
                        return try await studentClient.getStudentInfo()
                    }))
                    await send(.initTotalReportCardResponse(Result {
                        return try await gradeClient.getTotalReportCard()
                    }))
                }
            case .initStudentReponse(.success(let studentInfo)):
                state.studentInfo = studentInfo
                return .none
            case .initStudentReponse(.failure(let error)):
                debugPrint(error)
                return .none
            case .initTotalReportCardResponse(.success(let totalReportCard)):
                state.totalReportCard = totalReportCard
                return .none
            case .initTotalReportCardResponse(.failure(let error)):
                debugPrint(error)
                return .none
            case .checkPushAuthorizationResponse(.success(let granted)):
                state.$permission.withLock { $0 = granted }
                return .run { send in
                    await send(.sendTestPushResponse(Result {
                        try await localNotificationClient.setLecturePushNotification("Test")
                    }))
                }
            case .checkPushAuthorizationResponse(.failure(let error)):
                debugPrint("Home Reducer: CheckPushAuthorization Error - \(error)")
                return .none
            case .sendTestPushResponse:
                return .none
            case .settingPressed:
                debugPrint("== SettingView로 이동 ==")
                return .none
            case .semesterListPressed:
                debugPrint("== SemesterList로 이동 ==")
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}
