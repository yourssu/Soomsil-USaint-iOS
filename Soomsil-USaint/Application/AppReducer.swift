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
    enum State: Equatable {
        case initial
        case loggedOut
        case loggedIn
        
        init() {
            self = .initial
        }
    }
    
    enum Action {
        case `init`
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .`init`:
                state = .loggedOut
                return .none
            }
        }
    }
}
