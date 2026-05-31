//
//  AppView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import SwiftUI

import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppReducer>
    
    var body: some View {
        Group {
            switch store.state {
            case .initial:
                if let store = store.scope(state: \.initial, action: \.splash) {
                    SplashView(store: store)
                }
            case .loggedOut:
                if let store = store.scope(state: \.loggedOut, action: \.login) {
                    LoginView(store: store)
                }
            case .loggedIn:
                if let store = store.scope(state: \.loggedIn, action: \.mainTab) {
                    MainTabView(store: store)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .usaintNotificationOpened)) { notification in
            guard let routeValue = notification.userInfo?[NotificationUserInfoKey.route] as? String,
                  let route = USaintNotificationRoute(rawValue: routeValue) else {
                return
            }
            UserDefaults.standard.removeObject(forKey: NotificationStorageKey.pendingRoute)
            store.send(.notificationOpened(route))
        }
    }
}
