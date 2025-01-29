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
        @Presents var alert: AlertState<Action.Alert>?
        var path = StackState<Path.State>()
        var appState: AppReducer.State?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case logoutButtonTapped
        case togglePushAuthorization(Bool)
        case pushAuthorizationResponse(Result<Bool, Error>)
        case requestPushAuthorizationResponse(Result<Bool, Error>)
        case termsOfServiceButtonTapped
        case privacyPolicyButtonTapped
        case path(StackActionOf<Path>)
        case alert(PresentationAction<Alert>)
        case appState(AppReducer.Action)
        
        enum Alert: Equatable {
            case logout
            case configurePushAuthorization
        }
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .logoutButtonTapped:
                state.alert = AlertState {
                    TextState("로그아웃 하시겠습니까?")
                } actions: {
                    ButtonState(
                        role: .destructive,
                        action: .logout) {
                            TextState("로그아웃")
                        }
                    ButtonState(
                        role: .cancel) {
                            TextState("취소")
                        }
                }
                return .none
            case .alert(.presented(.logout)):
                debugPrint("settingReducer: logout")
                YDSToast("로그아웃", haptic: .success)
                state.appState = .loggedOut(LoginReducer.State())
                return .none
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
                    state.alert = AlertState {
                        TextState("알림 설정")
                    } actions: {
                        ButtonState(
                            role: .destructive,
                            action: .configurePushAuthorization
                        ) {
                            TextState("설정")
                        }
                        ButtonState(
                            role: .cancel) {
                                TextState("취소")
                            }
                    } message: {
                        TextState("알림에 대한 권한 사용을 거부하였습니다. 기능 사용을 원하실 경우 설정 > 앱 > 숨쉴때 유세인트 > 알림 권한 허용을 해주세요.")
                    }
                }
                return .none
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
            case .alert(.presented(.configurePushAuthorization)):
                debugPrint("alert permission")
                return .run { send in
                    await send(.requestPushAuthorizationResponse(Result {
                        try await localNotificationClient.requestPushAuthorization()
                    }))
                }
            case .termsOfServiceButtonTapped:
                state.path.append(
                    .navigateToTermsWebView(WebReducer.State(
                        url: URL(string: "https://auth.yourssu.com/terms/service.html")!)))
                return .none
            case .privacyPolicyButtonTapped:
                state.path.append(.navigateToTermsWebView(WebReducer.State(
                    url: URL(string: "https://auth.yourssu.com/terms/information.html")!)))
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.appState, action: \.appState) {
            AppReducer()
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.path, action: \.path)
    }
}

extension SettingReducer {
    @Reducer
    enum Path {
        case navigateToTermsWebView(WebReducer)
    }
}
