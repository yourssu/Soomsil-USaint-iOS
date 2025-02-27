//
//  SplashReducer.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 2/27/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct SplashReducer {
    @ObservableState
    struct State {
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action {
        case alert(PresentationAction<Alert>)
        case checkMinimumVersion
        case checkMinimumVersionResponse(Result<String, Error>)
        case initialize
        case initResponse(Result<StudentInfo, Error>)
        
        enum Alert: Equatable {
            case moveAppStoreTapped
        }
    }
    
    @Dependency(\.remoteConfigClient) var remoteConfigClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
