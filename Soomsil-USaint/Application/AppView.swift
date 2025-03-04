//
//  AppView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import SwiftUI

import ComposableArchitecture

struct AppView: View {
    @Perception.Bindable var store: StoreOf<AppReducer>
    
    var body: some View {
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
            if let store = store.scope(state: \.loggedIn, action: \.home) {
                HomeView(store: store)
            }
        }
    }
}
