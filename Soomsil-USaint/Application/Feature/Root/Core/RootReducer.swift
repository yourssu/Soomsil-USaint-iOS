//
//  RootReducer.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 2/3/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct RootReducer {
    @Reducer
    enum Path {
        case setting(SettingReducer)
//        case semesterList
//        case semesterDetail
        case web(WebReducer)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var home: HomeReducer.State
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case home(HomeReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.home, action: \.home) {
            HomeReducer()
        }
        Reduce { state, action in
            return .none
        }
        .forEach(\.path, action: \.path)
    }
}
