//
//  SemesterDetailReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import ComposableArchitecture

@Reducer
struct SemesterDetailReducer {
    @ObservableState
    struct State {
        var gradeList: [LectureDetail]
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}
