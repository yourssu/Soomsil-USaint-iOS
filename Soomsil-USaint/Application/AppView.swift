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
            SplashView()
                .task {
                    do {
                        try await Task.sleep(for: .seconds(3))
                        store.send(.`init`)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
        case .loggedIn:
            Text("Home")
        case .loggedOut:
            Text("Login")
        }
    }
}
