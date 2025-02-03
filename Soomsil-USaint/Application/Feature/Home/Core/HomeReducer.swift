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
        
        var studentInfo: StudentInfo
        var totalReportCard: TotalReportCard
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case checkPushAuthorizationResponse(Result<Bool, Error>)
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
                state.$isFirst.withLock { $0 = false }
                return .run { send in
                    await send(.checkPushAuthorizationResponse(Result {
                        if (isFirst) {
                            return try await localNotificationClient.requestPushAuthorization()
                        } else {
                            return await localNotificationClient.getPushAuthorizationStatus()
                        }
                    }))
                }
            case .checkPushAuthorizationResponse(.success(let granted)):
                state.$permission.withLock { $0 = granted }
                return .none
            case .checkPushAuthorizationResponse(.failure(let error)):
                debugPrint("Home Reducer: CheckPushAuthorization Error - \(error)")
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
