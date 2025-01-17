//
//  LoginReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct LoginReducer {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        
        var id = ""
        var password = ""
    }
    
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case loginPressed
        case loginResponse(Result<Void, Error>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            return .none
        }
    }
}
