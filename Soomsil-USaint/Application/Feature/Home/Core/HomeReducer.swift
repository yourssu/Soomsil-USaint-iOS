//
//  HomeReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct HomeReducer {
    @ObservableState
    struct State {
        @Shared(.appStorage("isFirstTest2")) var isFirst = true
    }
    
    enum Action {
        case onAppear
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                debugPrint("Home - Before: \(state.isFirst)")
                state.$isFirst.withLock { $0 = false }
                debugPrint("Home - After: \(state.isFirst)")
                return .none
            }
        }
    }
}
