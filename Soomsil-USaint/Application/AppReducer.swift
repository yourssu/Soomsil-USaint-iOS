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
        case loggedOut
        case loggedIn(HomeReducer.State)
        
        init() {
            self = .initial
        }
    }
    
    enum Action {
        case initialize
        case home(HomeReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .initialize:
                state = .loggedIn(HomeReducer.State())
                return .none
            default:
                return .none
            }
        }
        .ifCaseLet(\.loggedIn, action: \.home) {
            HomeReducer()
        }
    }
}
