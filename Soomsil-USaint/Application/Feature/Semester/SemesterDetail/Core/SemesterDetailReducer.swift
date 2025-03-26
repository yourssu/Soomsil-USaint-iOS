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
        var semesterList: [GradeSummary] = []
        var tabs: [SemesterTab] = []
        var activeTab: SemesterTab.ID = ""
        var isLoading: Bool = false
        var toastMessage: String?
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
                state.tabs = semesterList.map {
                    SemesterTab(id: "\($0.year)년 \($0.semester)")
                }
                state.activeTab = state.tabs.first?.id ?? ""
                state.isLoading = false
                return .none
            case .semesterListResponse(.failure(let error)):
                state.isLoading = false
                state.toastMessage = String(describing: error)
                return .none
            default:
                return .none
            }
        }
    }
}
