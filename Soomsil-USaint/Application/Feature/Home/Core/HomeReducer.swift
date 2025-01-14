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
    }
    
    enum Action {
        case onAppear
        case checkPushAuthorizationResponse(Result<Bool, Error>)
        case sendTestPushResponse(Result<Void, Error>)
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    
    var body: some Reducer<State, Action> {
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
                            return await localNotificationClient.getPushAuthorizationStatus()
                        }
                    }))
                }
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
            }
        }
    }
}
