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
    
    // TODO: 삭제 예정
    @State var isLoggedIn = HomeRepository.shared.hasCachedUserInformation
    
    var body: some View {
        switch store.state {
        case .initial:
            SplashView()
                .onAppear {
                    store.send(.initialize)
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
