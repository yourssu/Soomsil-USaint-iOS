//
//  SettingReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct SettingReducer {
    @ObservableState
    struct State {
        var isNotificationEnabled: Bool = LocalNotificationManager.shared.getNotificationPermission()
    }
    
    enum Action {
        case logoutButtonTapped
        case toggleNotificationButtonTapped
        case termsOfServiceButtonTapped
        case privacyPolicyButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
