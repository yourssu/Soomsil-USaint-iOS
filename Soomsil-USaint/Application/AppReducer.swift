//
//  AppReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct AppReducer {
    @ObservableState
    enum State {
        case initial
        case loggedOut(LoginReducer.State)
        case loggedIn(HomeReducer.State)
        
        init() {
            self = .initial
        }
    }
    
    enum Action {
        case initialize
        case backgroundTask
        case login(LoginReducer.Action)
        case home(HomeReducer.Action)
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize:
                state = .loggedOut(LoginReducer.State())
                return .none
            case .backgroundTask:
                debugPrint("AppReducer: backgroundTask")
                return .run { send in
                    @Shared(.appStorage("isFirst")) var isFirst = true
                    try await localNotificationClient.setLecturePushNotification("\(isFirst)")
                }
            default:
                return .none
            }
        }
        .ifCaseLet(\.loggedOut, action: \.login) {
            LoginReducer()
        }
        .ifCaseLet(\.loggedIn, action: \.home) {
            HomeReducer()
        }
    }
}
