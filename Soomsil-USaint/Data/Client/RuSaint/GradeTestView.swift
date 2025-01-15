//
//  GradeTestView.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 1/14/25.
//

import SwiftUI

import ComposableArchitecture
import Rusaint

struct GradeTestView: View {
    let store: StoreOf<GradeTestFeature>
    
    var body: some View {
        Button("test") {
            store.send(.onAppear)
        }
    }
}

@Reducer
struct GradeTestFeature {
    @ObservableState
    struct State {
        var grade = [SemesterGrade]()
    }
    
    enum Action {
        case onAppear
        case gradeRespnose(Result<[SemesterGrade], Error>)
    }
    
    @Dependency(\.gradeClient) var gradeClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.gradeRespnose(Result {
                        try await gradeClient.fetchAllSemesterGrades()
                    }))
                }
            case let .gradeRespnose(.success(response)):
                state.grade = response
                return .none
            case .gradeRespnose(.failure(_)):
                return .none
            }
        }
    }
}

#Preview {
    GradeTestView(
        store: Store(initialState: GradeTestFeature.State()) {
            GradeTestFeature()
        }
    )
}
