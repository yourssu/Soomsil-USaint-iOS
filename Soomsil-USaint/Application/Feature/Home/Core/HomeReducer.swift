//
//  HomeReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct HomeReducer {
    @ObservableState
    struct State {
        var studentInfo: StudentInfo
        var totalReportCard: TotalReportCard
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case settingPressed
        case semesterListPressed
    }
    
    @Dependency(\.studentClient) var studentClient
    @Dependency(\.gradeClient) var gradeClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .settingPressed:
                debugPrint("== SettingView로 이동 ==")
                return .none
            case .semesterListPressed:
                debugPrint("== SemesterList로 이동 ==")
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}
