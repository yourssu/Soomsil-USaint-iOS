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
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case logoutButtonTapped
        case togglePushAuthorization(Bool)
        case pushAuthorizationResponse(Result<Bool, Error>)
        case requestPushAuthorizationResponse(Result<Bool, Error>)
        case termsOfServiceButtonTapped
        case privacyPolicyButtonTapped
        case alert(PresentationAction<Alert>)
        
        enum Alert: Equatable {
            case confirmLogoutTapped
            case configurePushAuthorizationTapped
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
                        action: .confirmLogoutTapped) {
                            TextState("로그아웃")
                        }
                    ButtonState(
                        role: .cancel) {
                            TextState("취소")
                        }
                }
                return .none
            case .alert(.presented(.confirmLogoutTapped)):
                YDSToast("로그아웃 완료", haptic: .success)
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
                            action: .configurePushAuthorizationTapped
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
                } else {
                    YDSToast("알림권한 허용", haptic: .success)
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
            case .alert(.presented(.configurePushAuthorizationTapped)):
                debugPrint("alert permission")
                return .run { send in
                    await send(.requestPushAuthorizationResponse(Result {
                        try await localNotificationClient.requestPushAuthorization()
                    }))
                }
            default:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
