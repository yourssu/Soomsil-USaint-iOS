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
        var semesterList: [GradeSummary] = []
        var currentSemesterLectures: [LectureDetail] = []
        var isLoading: Bool = false
        var toastMessage: String = ""
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
        case getGradeDataResponse(Result<[GradeSummary], Error>)
        case fetchGradeDataResponse(Result<Void, Error>)
        case fetchCurrentSemesterGradeResponse(Result<[LectureDetail], Error>)
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
                state.isLoading = true
                let isFirst = state.isFirst
                state.$isFirst.withLock { $0 = false }
                return .run { send in
                    /// 알림 권한 확인
                    await send(.checkPushAuthorizationResponse(Result {
                        if (isFirst) {
                            return try await localNotificationClient.requestPushAuthorization()
                        } else {
                            return await localNotificationClient.getPushAuthorizationStatus()
                        }
                    }))
                    
                    /// TotalReportCard 정보를 위한 GradeSummary 정보 불러옴
                    do {
                        await send(.getGradeDataResponse(.success(
                            try await gradeClient.getAllSemesterGrades()
                        )))
                    } catch {
                        await send(.getGradeDataResponse(.failure(error)))
                    }
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
                state.isLoading = true
                return .run { send in
                    await send(.fetchCurrentSemesterGradeResponse(Result {
                        if let currentSemester = try await gradeClient.currentYearAndSemester() {
                            let lectures = try await gradeClient.fetchGrades(currentSemester.year,
                                                                           currentSemester.semester)
                            return lectures.toLectureDetails()
                        } else {
                            let lectures = try await gradeClient.fetchGrades(2025,
                                                                             .one)
                            return lectures.toLectureDetails()
                        }
                    }))
                }
            case .currentSemesterGradesDismissed:
                state.currentSemesterGrades = false
                return .none
            case .semesterGradesPressed:
                state.path.append(.semesterDetail(SemesterDetailReducer.State()))
                return .none
            case .getGradeDataResponse(.success(let semesterList)):
                if(semesterList.isEmpty) {
                    return .run { send in
                        await send(.fetchGradeDataResponse(Result {
                            try await fetchGradeData()
                            
                            do {
                                await send(.getGradeDataResponse(.success(
                                    try await gradeClient.getAllSemesterGrades()
                                )))
                            } catch {
                                await send(.getGradeDataResponse(.failure(error)))
                            }
                            
                        }))
                    }
                }
                state.semesterList = semesterList.sortedDescending()
                state.totalReportCard.generalRank = semesterList.first?.overallRank ?? 0
                state.totalReportCard.overallStudentCount = semesterList.first?.overallStudentCount ?? 0
                state.isLoading = false
                return .none
            case .getGradeDataResponse(.failure(let error)):
                state.isLoading = false
                state.toastMessage = String(describing: error)
                return .none
            case .fetchCurrentSemesterGradeResponse(.success(let lectures)):
                state.currentSemesterLectures = lectures
                state.isLoading = false
                return .none
            case .fetchCurrentSemesterGradeResponse(.failure(let error)):
                state.toastMessage = String(describing: error)
                state.isLoading = false
                return .none
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
    
    private func fetchGradeData() async throws {
        try await gradeClient.deleteTotalReportCard()
        try await gradeClient.deleteAllSemesterGrades()
        let totalReportCard = try await gradeClient.fetchTotalReportCard()
        try await gradeClient.updateTotalReportCard(totalReportCard)
        let allSemesterGrades = try await gradeClient.fetchAllSemesterGrades()
        try await gradeClient.updateAllSemesterGrades(allSemesterGrades)
    }
}
