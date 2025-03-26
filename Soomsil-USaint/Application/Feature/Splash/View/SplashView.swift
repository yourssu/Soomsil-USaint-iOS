//
//  SplashView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import SwiftUI

import ComposableArchitecture

struct SplashView: View {
    @Bindable var store: StoreOf<SplashReducer>

    var body: some View {
        Image("splash")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .alert($store.scope(state: \.alert, action: \.alert))
            .onAppear {
                store.send(.checkMinimumVersion)
            }
    }
}

#Preview {
    SplashView(store: Store(initialState: SplashReducer.State()) {
        SplashReducer()
    })
}
