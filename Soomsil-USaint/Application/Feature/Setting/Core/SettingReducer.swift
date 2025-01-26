//
//  SettingReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import UIKit

import ComposableArchitecture
import YDS_SwiftUI

@Reducer
struct SettingReducer {
    @ObservableState
    struct State {
        @Shared(.appStorage("permission")) var permission = false
        var alert: ActiveAlert? = nil
        var path = StackState<Path.State>()
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case logoutButtonTapped
        case togglePushAuthorization(Bool)
        case pushAuthorizationResponse(Result<Bool, Error>)
        case configureSettingTapped
        case requestPushAuthorizationResponse(Result<Bool, Error>)
        case termsOfServiceButtonTapped
        case privacyPolicyButtonTapped
        case path(StackActionOf<Path>)
    }
    
    @Reducer(state: .equatable)
    enum Path {
        case navigateToTermsWebView(WebReducer)
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .togglePushAuthorization(true):
                return .run { send in
                    await send(.pushAuthorizationResponse(Result {
                        await localNotificationClient.getPushAuthorizationStatus()
                    }))
                }
            case .togglePushAuthorization(false):
                state.$permission.withLock { $0 = false }
                return .none
            case .pushAuthorizationResponse(.success(let granted)):
                state.$permission.withLock { $0 = granted }
                if !granted {
                    state.alert = .permission
                }
                return .none
            case .configureSettingTapped:
                return .run { send in
                    await send(.requestPushAuthorizationResponse(Result {
                        return try await localNotificationClient.requestPushAuthorization()
                    }))
                }
            case .requestPushAuthorizationResponse(.success(let granted)):
                if !granted {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        DispatchQueue.main.async {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
                return .none
                        
            case .logoutButtonTapped:
                YDSToast("logoutButtonTapped 성공하였습니다.", haptic: .success)
                return .none
            case .termsOfServiceButtonTapped:
                state.path.append(.navigateToTermsWebView(WebReducer.State(url: URL(string: "https://auth.yourssu.com/terms/service.html")!)))
                return .none
            case .privacyPolicyButtonTapped:
                state.path.append(.navigateToTermsWebView(WebReducer.State(url: URL(string: "https://auth.yourssu.com/terms/information.html")!)))
                return .none
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
