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
    @Reducer
    enum Path {
        case setting(SettingReducer)
        case semesterList(SemesterListReducer)
        case semesterDetail(SemesterDetailReducer)
        case web(WebReducer)
    }
    
    @ObservableState
    struct State {
        @Shared(.appStorage("isFirst")) var isFirst = true
        @Shared(.appStorage("permission")) var permission = false
        
        var path = StackState<Path.State>()
        
         var currentSemesterGrades = false
        
        var studentInfo: StudentInfo
        var totalReportCard: TotalReportCard
        var chapelCard: ChapelCard
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case onAppear
        case checkPushAuthorizationResponse(Result<Bool, Error>)
        case settingPressed
        case semesterListPressed
        case semesterDetailPressed

        case currentSemesterGradesPressed
        case currentSemesterGradesDismissed
        case semesterGradesPressed
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    @Dependency(\.studentClient) var studentClient
    @Dependency(\.gradeClient) var gradeClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .path(let action):
                switch action {
                case .element(id: _, action: .setting(.termsOfServiceButtonTapped)):
                    state.path.append(.web(WebReducer.State(
                        url: URL(string: "https://auth.yourssu.com/terms/service.html")!
                    )))
                    return .none
                case .element(id: _, action: .setting(.privacyPolicyButtonTapped)):
                    state.path.append(.web(WebReducer.State(
                        url: URL(string: "https://auth.yourssu.com/terms/information.html")!
                    )))
                    return .none
                default:
                    return .none
                }
            case .onAppear:
                let isFirst = state.isFirst
                state.$isFirst.withLock { $0 = false }
                return .run { send in
                    await send(.checkPushAuthorizationResponse(Result {
                        if (isFirst) {
                            return try await localNotificationClient.requestPushAuthorization()
                        } else {
                            return await localNotificationClient.getPushAuthorizationStatus()
                        }
                    }))
                }
            case .checkPushAuthorizationResponse(.success(let granted)):
                state.$permission.withLock { $0 = granted }
                return .none
            case .checkPushAuthorizationResponse(.failure(let error)):
                debugPrint("Home Reducer: CheckPushAuthorization Error - \(error)")
                return .none
            case .settingPressed:
                state.path.append(.setting(SettingReducer.State()))
                return .none
            case .semesterListPressed:
                state.path.append(.semesterList(SemesterListReducer.State(totalReportCard: state.totalReportCard)))
                return .none
            case .semesterDetailPressed:
                state.path.append(.semesterDetail(SemesterDetailReducer.State()))
                return .none
            case .currentSemesterGradesPressed:
                state.currentSemesterGrades = true
                return .none
            case .semesterGradesPressed:
                state.path.append(.semesterDetail(SemesterDetailReducer.State()))
                return .none
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
