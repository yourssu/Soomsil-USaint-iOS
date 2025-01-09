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
    
    // TODO: 삭제 예정
    @State var isLoggedIn = HomeRepository.shared.hasCachedUserInformation
    
    var body: some View {
        switch store.state {
        case .initial:
            SplashView()
                .task {
                    do {
                        try await Task.sleep(for: .seconds(3))
                        store.send(.initialize)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
        case .loggedIn:
            HomeView(viewModel: DefaultSaintHomeViewModel(), isLoggedIn: $isLoggedIn)
        case .loggedOut:
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}