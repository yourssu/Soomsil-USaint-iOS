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

        var appVersion: String = "-"
        var showsLogoutDialog = false
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case backButtonTapped
        case logoutButtonTapped
        case logoutCancelTapped
        case logoutConfirmed
        case logoutCompleted
        case togglePushAuthorization(Bool)
        case syncPushAuthorizationResponse(Result<Bool, Error>)
        case pushAuthorizationResponse(Result<Bool, Error>)
        case requestPushAuthorizationResponse(Result<Bool, Error>)
        case notificationCategoryToggled(USaintNotificationCategory, Bool)
        case termsOfServiceButtonTapped
        case privacyPolicyButtonTapped
        case alert(PresentationAction<Alert>)

        enum Alert: Equatable {
            case confirmLogoutTapped
            case configurePushAuthorizationTapped
        }
    }

    @Dependency(\.localNotificationClient) var localNotificationClient
    @Dependency(\.remoteNotificationClient) var remoteNotificationClient
    @Dependency(\.studentClient) var studentClient
    @Dependency(\.gradeClient) var gradeClient
    @Dependency(\.chapelClient) var chapelClient
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    state.appVersion = currentVersion
                }
                return .run { _ in
                    await remoteNotificationClient.syncTopicSubscriptions()
                }
            case .backButtonTapped:
                return .run { _ in
                    await dismiss()
                }
            case .logoutButtonTapped:
                state.showsLogoutDialog = true
                return .none
            case .logoutCancelTapped:
                state.showsLogoutDialog = false
                return .none
            case .alert(.presented(.confirmLogoutTapped)):
                return .send(.logoutConfirmed)
            case .logoutConfirmed:
                state.showsLogoutDialog = false
                return .run { send in
                    try await gradeClient.deleteTotalReportCard()
                    try await gradeClient.deleteAllSemesterGrades()
                    try await studentClient.deleteStudentInfo()
                    try await chapelClient.deleteChapelCard()

                    YDSToast(TextLiteral.SettingReducer.logoutSuccessToast, haptic: .success)

                    await send(.logoutCompleted)
                }
            case .togglePushAuthorization(true):
                return .run { send in
                    await send(.pushAuthorizationResponse(Result {
                        await localNotificationClient.getPushAuthorizationStatus()
                    }))
                }
            case .togglePushAuthorization(false):
                state.$permission.withLock { $0 = false }
                YDSToast(TextLiteral.SettingReducer.pushAuthorizationDeniedToast, haptic: .success)
                return .run { _ in
                    await remoteNotificationClient.syncTopicSubscriptions()
                }
            case .syncPushAuthorizationResponse(.success(let granted)):
                state.$permission.withLock { $0 = granted }
                return .run { _ in
                    await remoteNotificationClient.syncTopicSubscriptions()
                }
            case .syncPushAuthorizationResponse(.failure(let error)):
                debugPrint("Setting Reducer: SyncPushAuthorization Error - \(error)")
                return .none
            case .pushAuthorizationResponse(.success(let granted)):
                state.$permission.withLock { $0 = granted }
                if !granted {
                    state.alert = AlertState {
                        TextState(TextLiteral.SettingReducer.pushAuthorizationAlertTitle)
                    } actions: {
                        ButtonState(
                            role: .destructive,
                            action: .configurePushAuthorizationTapped
                        ) {
                            TextState(TextLiteral.SettingReducer.pushAuthorizationAlertConfirmTitle)
                        }
                        ButtonState(
                            role: .cancel) {
                                TextState(TextLiteral.SettingReducer.alertCancelTitle)
                            }
                    } message: {
                        TextState(TextLiteral.SettingReducer.pushAuthorizationAlertMessage)
                    }
                } else {
                    YDSToast(TextLiteral.SettingReducer.pushAuthorizationAllowedToast, haptic: .success)
                }
                return .run { _ in
                    if granted {
                        await remoteNotificationClient.registerDeviceIfAuthorized()
                    }
                    await remoteNotificationClient.syncTopicSubscriptions()
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
            case .notificationCategoryToggled(let category, let isEnabled):
                return .run { _ in
                    await remoteNotificationClient.updateTopicSubscription(category, isEnabled)
                }
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
