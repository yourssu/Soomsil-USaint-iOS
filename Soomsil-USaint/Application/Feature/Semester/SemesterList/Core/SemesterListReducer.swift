//
//  SemesterListReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture
import YDS_SwiftUI

@Reducer
struct SemesterListReducer {
    @ObservableState
    struct State {
        var totalReportCard: TotalReportCard = TotalReportCard(gpa: 4.5, earnedCredit: 133.0, graduateCredit: 123.0)
        var semesterList: [GradeSummary] = []
        var fetchErrorMessage: String = "재로그인 후 다시 시도해주세요!"
        var isLoading: Bool = true
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onRefresh
        case totalReportCardResponse(Result<TotalReportCard, Error>)
        case semesterListResponse(Result<[GradeSummary], Error>)
    }

    @Dependency(\.studentClient) var studentClient
    @Dependency(\.gradeClient) var gradeClient

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.totalReportCardResponse(Result {
                        return try await gradeClient.getTotalReportCard()
                    }))
                    await send(.semesterListResponse(Result {
                        return try await gradeClient.getAllSemesterGrades()
                    }))
                }
            case .onRefresh:
                state.isLoading = true
                return .run { send in
                do {
                       try await gradeClient.deleteTotalReportCard()
                       try await gradeClient.deleteAllSemesterGrades()

                       let totalReportCard = try await gradeClient.fetchTotalReportCard()
                       try await gradeClient.updateTotalReportCard(totalReportCard)

                       let allSemesterGrades = try await gradeClient.fetchAllSemesterGrades()
                       try await gradeClient.updateAllSemesterGrades(allSemesterGrades)

                       await send(.totalReportCardResponse(Result {
                           return try await gradeClient.getTotalReportCard()
                       }))
                       await send(.semesterListResponse(Result {
                           return try await gradeClient.getAllSemesterGrades()
                       }))
                   } catch {
                       debugPrint("onRefresh failed: \(error)")
                       await send(.semesterListResponse(.failure(error)))
                   }
                }
            case .totalReportCardResponse(.success(let totalReportCard)):
                state.totalReportCard = totalReportCard
                state.isLoading = false
                return .none
            case .totalReportCardResponse(.failure(let error)):
                debugPrint(error)
                state.isLoading = false
                YDSToast(String(describing: state.fetchErrorMessage), haptic: .failed)
                return .none
            case .semesterListResponse(.success(let semesterList)):
                state.semesterList = semesterList
                state.isLoading = false
                return .none
            case .semesterListResponse(.failure(let error)):
                debugPrint(error)
                state.isLoading = false
                YDSToast(String(describing: state.fetchErrorMessage), haptic: .failed)
                return .none
            default:
                return .none
            }
        }
    }

}
