//
//  WebReducer.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 1/27/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct WebReducer {
    
    @ObservableState
    struct State {
        let url: URL
    }
    
    enum Action {
        case dismiss
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .run { _ in
                    await self.dismiss()
                }
            }
        }
    }
}
