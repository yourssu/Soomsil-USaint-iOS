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
        case semesterDetail(SemesterDetailReducer)
        case web(WebReducer)
    }
    
    @ObservableState
    struct State {
        @Shared(.appStorage("isFirst")) var isFirst = true
        @Shared(.appStorage("permission")) var permission = false
        
        var path = StackState<Path.State>()
        
        @Presents var currentSemesterGrades: CurrentSemesterGradesReducer.State?
        
        var studentInfo: StudentInfo
        var totalReportCard: TotalReportCard
        var chapelCard: ChapelCard
        var semesterList: [GradeSummary] = []
        var isLoading: Bool = false
        var toastMessage: String = ""
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case onAppear
        case checkPushAuthorizationResponse(Result<Bool, Error>)
        case notificationPermissionResponse(Result<Bool, Error>)
        case semesterDetailPressed

        case currentSemesterGradesPressed
        case currentSemesterGrades(PresentationAction<CurrentSemesterGradesReducer.Action>)
        case semesterGradesPressed
        case chapelAttendancePressed
        case getGradeDataResponse(Result<[GradeSummary], Error>)
        case getChapelDataResponse(Result<ChapelCard, Error>)
        case fetchGradeDataResponse(Result<Void, Error>)
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    @Dependency(\.remoteNotificationClient) var remoteNotificationClient
    @Dependency(\.alarmBackendClient) var alarmBackendClient
    @Dependency(\.studentClient) var studentClient
    @Dependency(\.gradeClient) var gradeClient
    @Dependency(\.chapelClient) var chapelClient
    @Dependency(\.mixpanelClient) var mixpanelClient

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .path:
                return .none
            case .onAppear:
                state.isLoading = true
                let isFirst = state.isFirst
                state.$isFirst.withLock { $0 = false }

                return .run { send in
                    // 비동기로 채플 정보 fetch
                    async let chapelTask = retryWithExponentialBackoff(
                        base: 0.5,
                        maxInterval: 10,
                        maxAttempts: 3
                    ) { try await fetchChapelData() }

                    // 먼저 기존 값 보여주기
                    do {
                        await send(.getGradeDataResponse(.success(
                            try await gradeClient.getAllSemesterGrades()
                        )))
                    } catch {
                        await send(.getGradeDataResponse(.failure(error)))
                    }

                    if isFirst {
                        await send(.notificationPermissionResponse(Result {
                            try await localNotificationClient.requestPushAuthorization()
                        }))
                    } else {
                        await send(.checkPushAuthorizationResponse(Result {
                            await localNotificationClient.getPushAuthorizationStatus()
                        }))
                    }

                    // 서버에서 최신 값 다시 fetch
                    await send(.fetchGradeDataResponse(Result {
                        try await fetchGradeData()
                    }))

                    // 최신 데이터 다시 불러오기
                    do {
                        await send(.getGradeDataResponse(.success(
                            try await gradeClient.getAllSemesterGrades()
                        )))
                    } catch {
                        await send(.getGradeDataResponse(.failure(error)))
                    }
                    
                    // 지수 백오프로 재시도한 채플 정보 처리
                    do {
                        let chapelResult = try await chapelTask
                        await send(.getChapelDataResponse(.success(chapelResult)))
                    } catch {
                        await send(.getChapelDataResponse(.failure(error)))
                    }
                }

            case .checkPushAuthorizationResponse(.success(let granted)):
                state.$permission.withLock { $0 = granted }
                return .run { _ in
                    if granted {
                        await remoteNotificationClient.registerDeviceIfAuthorized()
                        try? await alarmBackendClient.registerStoredDevice()
                    }
                    await remoteNotificationClient.syncTopicSubscriptions()
                }
            case .checkPushAuthorizationResponse(.failure(let error)):
                debugPrint("Home Reducer: CheckPushAuthorization Error - \(error)")
                return .none
            case .notificationPermissionResponse(.success(let granted)):
                state.$permission.withLock { $0 = granted }
                return .run { _ in
                    if granted {
                        await remoteNotificationClient.registerDeviceIfAuthorized()
                        try? await alarmBackendClient.registerStoredDevice()
                    }
                    await remoteNotificationClient.syncTopicSubscriptions()
                }
            case .notificationPermissionResponse(.failure(let error)):
                debugPrint("Home Reducer: RequestPushAuthorization Error - \(error)")
                state.$permission.withLock { $0 = false }
                return .run { _ in
                    await remoteNotificationClient.syncTopicSubscriptions()
                }
            case .semesterDetailPressed:
                state.path.append(.semesterDetail(SemesterDetailReducer.State()))
                return .none
            case .currentSemesterGradesPressed:
                let student = state.studentInfo
                let saintId = Int(StudentClient.keychain["saintID"] ?? "") ?? -1

                let (event, props) = AnalyticsEvent.thisSemesterGradeClick(student: student, saintId: saintId)
                mixpanelClient.track(event, properties: props)

                state.currentSemesterGrades = CurrentSemesterGradesReducer.State()
                return .none
            case .semesterGradesPressed:
                let student = state.studentInfo
                let saintId = Int(StudentClient.keychain["saintID"] ?? "") ?? -1
                let chapel = state.chapelCard.status == .active  

                let (event, props) = AnalyticsEvent.allSemesterGradeClick(
                    student: student,
                    saintId: saintId,
                    chapel: chapel
                )
                mixpanelClient.track(event, properties: props)
                state.path.append(.semesterDetail(SemesterDetailReducer.State()))
                return .none
            case .chapelAttendancePressed:
                let student = state.studentInfo
                let saintId = Int(StudentClient.keychain["saintID"] ?? "") ?? -1
                let chapel = state.chapelCard.status == .active

                let (event, props) = AnalyticsEvent.chapelCheckClick(
                    student: student,
                    saintId: saintId,
                    chapel: chapel
                )
                mixpanelClient.track(event, properties: props)
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
                
            case .getChapelDataResponse(.success(let chapel)):
                state.chapelCard = chapel
                NSLog("[채플] 정보 업데이트 완료")
                return .none
            case .getChapelDataResponse(.failure(let error)):
                NSLog("[채플] 업데이트 실패: \(String(describing: error))")
                return .none
                
            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$currentSemesterGrades, action: \.currentSemesterGrades) {
            CurrentSemesterGradesReducer()
        }
    }
    
    private func fetchGradeData() async throws {
        try await gradeClient.deleteTotalReportCard()
        try await gradeClient.deleteAllSemesterGrades()
        let totalReportCard = try await gradeClient.fetchTotalReportCard()
        try await gradeClient.updateTotalReportCard(totalReportCard)
        let allSemesterGrades = try await gradeClient.fetchAllSemesterGrades()
        try await gradeClient.updateAllSemesterGrades(allSemesterGrades)
    }
    
    private func fetchChapelData() async throws -> ChapelCard {
        try await chapelClient.deleteChapelCard()
        let chapelCard = try await chapelClient.fetchChapelCard()
        try await chapelClient.updateChapelCard(chapelCard)
        return chapelCard
    }
    
    enum ExponentialBackoffError: Error {
        case retryLimitExceeded
    }
    
    func retryWithExponentialBackoff<Result>(
        base: Double,
        maxInterval: Double,
        maxAttempts: Int,
        operation: () async throws -> Result
    ) async throws -> Result {
        var attempt = 0
        
        while attempt < maxAttempts {
            try Task.checkCancellation()
            
            do {
                NSLog("[채플] 업데이트 시도 \(attempt + 1)")
                return try await operation()
            } catch {
                // 마지막 시도일때 에러 던지기
                if attempt == maxAttempts - 1 {
                    throw error
                }
            }
            
            // 지수백오프 Jitter 적용
            let sleep = base * Double(pow(Double(2), Double(attempt)))
            let seconds = Double.random(in: 0...min(maxInterval, sleep))
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            
            attempt += 1
        }
        throw ExponentialBackoffError.retryLimitExceeded
    }

}
