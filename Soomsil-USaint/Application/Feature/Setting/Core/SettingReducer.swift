//
//  SettingReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct SettingReducer {
    @ObservableState
    struct State {
        var testStudentInfo: StudentInfo?
    }

    enum Action {
        case onAppear
        case getStudentInfo(StudentInfo)
    }

    @Dependency(\.studentClient) var studentClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    try await studentClient.setStudentInfo()
                    let info = try await studentClient.getStudentInfo()
                    await send(.getStudentInfo(info))
                } catch: { error, send in
                    print("SettingReducer: \(error)")
                }
            case let .getStudentInfo(info):
                state.testStudentInfo = info
                return .none
            }
        }
    }
}
