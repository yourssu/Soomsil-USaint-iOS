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
        case initResponse(Result<Void, Error>)
        case backgroundTask
        case login(LoginReducer.Action)
        case home(HomeReducer.Action)
        case logout
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    @Dependency(\.studentClient) var studentClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize:
                return .run { send in
                    await send(.initResponse(Result {
                        let _ = try await studentClient.getSaintInfo()
                    }))
                }
            case .initResponse(.success):
                state = .loggedIn(HomeReducer.State())
                return .none
            case .initResponse(.failure(let error)):
                debugPrint(error)
                state = .loggedOut(LoginReducer.State())
                return .none
            case .backgroundTask:
                debugPrint("AppReducer: backgroundTask")
                return .run { send in
                    @Shared(.appStorage("isFirst")) var isFirst = true
                    try await localNotificationClient.setLecturePushNotification("\(isFirst)")
                }
            case .login(.loginResponse(.success)):
                state = .loggedIn(HomeReducer.State())
                return .none
            case .logout:
                debugPrint("AppReducer: logout")
                state = .loggedOut(LoginReducer.State())
                return .none
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
