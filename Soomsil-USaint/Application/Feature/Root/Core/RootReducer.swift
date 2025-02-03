//
//  RootReducer.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 2/3/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct RootReducer {
    @Reducer
    enum Path {
        case setting(SettingReducer)
//        case semesterList
//        case semesterDetail
        case web(WebReducer)
    }
    
    @ObservableState
    struct State {
        @Shared(.appStorage("isFirst")) var isFirst = true
        @Shared(.appStorage("permission")) var permission = false
        
        var path = StackState<Path.State>()
        var home: HomeReducer.State
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case home(HomeReducer.Action)
        
        case onAppear
        case checkPushAuthorizationResponse(Result<Bool, Error>)
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    
    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) {
            HomeReducer()
        }
        Reduce { state, action in
            debugPrint(action)
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
            case .home(.settingPressed):
                state.path.append(.setting(SettingReducer.State()))
                return .none
            case .path(let action):
                switch action {
                case .element(id: _, action: .setting(.termsOfServiceButtonTapped)):
                    state.path.append(.web(WebReducer.State(
                        url: URL(string: "https://auth.yourssu.com/terms/service.html")!
                    )))
                    return .none
                case .element(id: _, action: .setting(.privacyPolicyButtonTapped)):
                    state.path.append(.web(WebReducer.State(
                        url: URL(string: "https://auth.yourssu.com/terms/information.html")!
                    )))
                    return .none
                default:
                    return .none
                }
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
