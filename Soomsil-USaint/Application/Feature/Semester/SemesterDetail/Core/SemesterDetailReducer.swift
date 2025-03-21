//
//  SemesterDetailReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import ComposableArchitecture
import YDS_SwiftUI

@Reducer
struct SemesterDetailReducer {
    @ObservableState
    struct State {
        var semesterList: [GradeSummary] = []
        var isLoading: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case refresh
        case semesterListResponse(Result<[GradeSummary], Error>)
    }
    
    @Dependency(\.gradeClient) var gradeClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.semesterListResponse(Result {
                        try await gradeClient.getAllSemesterGrades()
                    }))
                }
            case .refresh:
                return .none
            case .semesterListResponse(.success(let semesterList)):
                state.semesterList = semesterList
                state.isLoading = false
                return .none
            case .semesterListResponse(.failure(let error)):
                debugPrint(error)
                state.isLoading = false
                YDSToast(String(describing: error), haptic: .failed)
                return .none
            default:
                return .none
            }
        
        }
    }
}
