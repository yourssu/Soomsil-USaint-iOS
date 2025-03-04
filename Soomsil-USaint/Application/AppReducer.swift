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
        case initial(SplashReducer.State)
        case loggedOut(LoginReducer.State)
        case loggedIn(HomeReducer.State)
        
        init() {
            self = .initial(SplashReducer.State())
        }
    }
    
    enum Action {
        case backgroundTask
        case splash(SplashReducer.Action)
        case login(LoginReducer.Action)
        case home(HomeReducer.Action)
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .backgroundTask:
                debugPrint("AppReducer: backgroundTask")
                return .run { send in
                    @Shared(.appStorage("isFirst")) var isFirst = true
                    try await localNotificationClient.setLecturePushNotification("\(isFirst)")
                }
            case .splash(.initResponse(.success(let (studentInfo, totalReportCard)))):
                state = .loggedIn(HomeReducer.State(studentInfo: studentInfo, totalReportCard: totalReportCard))
                return .none
            case .splash(.initResponse(.failure)):
                state = .loggedOut(LoginReducer.State())
                return .none
            case .login(.loginResponse(.success(let (info, report)))):
                state = .loggedIn(HomeReducer.State(studentInfo: info, totalReportCard: report))
                return .none
            case .home(.path(.element(id: _, action: .setting(.alert(.presented(.logout)))))):
                state = .loggedOut(LoginReducer.State())
                return .none
            default:
                return .none
            }
        }
        .ifCaseLet(\.initial, action: \.splash) {
            SplashReducer()
        }
        .ifCaseLet(\.loggedOut, action: \.login) {
            LoginReducer()
        }
        .ifCaseLet(\.loggedIn, action: \.home) {
            HomeReducer()
        }
    }
}
