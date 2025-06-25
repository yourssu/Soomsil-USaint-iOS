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
        case refreshButtonTapped
        case backButtonTapped
        case semesterListResponse(Result<[GradeSummary], Error>)
    }
    
    @Dependency(\.gradeClient) var gradeClient
    @Dependency(\.dismiss) var dismiss
    
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
            case .refreshButtonTapped:
                state.isLoading = true
                return .run { send in
                    do {
                        try await refreshGradeData()
                        await send(.semesterListResponse(.success(
                            try await gradeClient.getAllSemesterGrades()
                        )))
                    } catch {
                        await send(.semesterListResponse(.failure(error)))
                    }
                }
            case .backButtonTapped:
                return .run { _ in
                    await dismiss()
                }
            case .semesterListResponse(.success(let semesterList)):
                guard !semesterList.isEmpty
                else {
                    return .run { send in
                        do {
                            try await refreshGradeData()
                            await send(.semesterListResponse(.success(
                                try await gradeClient.getAllSemesterGrades()
                            )))
                        } catch {
                            await send(.semesterListResponse(.failure(error)))
                        }
                    }
                }

                let descendingList = semesterList.sortedDescending()
                state.semesterList = descendingList
                state.tabs = descendingList.map {
                    SemesterTab(id: "\($0.year)년 \($0.semester)")
                }
                if state.activeTab.isEmpty { state.activeTab = state.tabs.first?.id ?? "" }
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

    private func refreshGradeData() async throws {
        try await gradeClient.deleteTotalReportCard()
        try await gradeClient.deleteAllSemesterGrades()

        let totalReportCard = try await gradeClient.fetchTotalReportCard()
        try await gradeClient.updateTotalReportCard(totalReportCard)

        let allSemesterGrades = try await gradeClient.fetchAllSemesterGrades()
        try await gradeClient.updateAllSemesterGrades(allSemesterGrades)
    }
}
