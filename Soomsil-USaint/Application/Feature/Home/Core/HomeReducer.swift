//
//  HomeReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation

import ComposableArchitecture
import UIKit

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
        case getChapelDataResponse(Result<ChapelCard, Error>)
        case fetchChapelDataResponse(Result<ChapelCard, Error>)
        case fetchGradeDataResponse(Result<Void, Error>)
        case fetchCurrentSemesterGradeResponse(Result<[LectureDetail], Error>)

        //MARK: - Events

        case openGiftLinkPressed
    }
    
    @Dependency(\.localNotificationClient) var localNotificationClient
    @Dependency(\.studentClient) var studentClient
    @Dependency(\.gradeClient) var gradeClient
    @Dependency(\.chapelClient) var chapelClient
    @Dependency(\.mixpanelClient) var mixpanelClient

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
                    // 비동기로 채플 정보 fetch
                    async let chapelTask = fetchChapelData()

                    // 먼저 기존 값 보여주기
                    do {
                        await send(.getGradeDataResponse(.success(
                            try await gradeClient.getAllSemesterGrades()
                        )))
                    } catch {
                        await send(.getGradeDataResponse(.failure(error)))
                    }

                    // 알림 권한 요청
                    await send(.checkPushAuthorizationResponse(Result {
                        if (isFirst) {
                            return try await localNotificationClient.requestPushAuthorization()
                        } else {
                            return await localNotificationClient.getPushAuthorizationStatus()
                        }
                    }))

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
                    
                    /// 새로운 fetch한 채플 정보
                    do {
                        let chapelResult = try await chapelTask
                        await send(.getChapelDataResponse(.success(chapelResult)))
                        debugPrint("채플 정보 업데이트 완료")
                    } catch {
                        await send(.getChapelDataResponse(.failure(error)))
                        debugPrint("채플 정보 업데이트 실패")
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
                let student = state.studentInfo
                let saintId = Int(StudentClient.keychain["saintID"] ?? "") ?? -1

                let (event, props) = AnalyticsEvent.thisSemesterGradeClick(student: student, saintId: saintId)
                mixpanelClient.track(event, properties: props)

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
                return .none
            case .getChapelDataResponse(.failure(let error)):
                debugPrint("첫번째 채플 : \(String(describing: error))")
                
                // fetch 재시도
                return .run { send in
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    
                    await send(.fetchChapelDataResponse(Result {
                        try await fetchChapelData()
                    }))
                }
                
            case .fetchChapelDataResponse(.success(let chapel)):
                state.chapelCard = chapel
                debugPrint("두번째 채플 fetch 성공")
                return .none
            case .fetchChapelDataResponse(.failure(let error)):
                debugPrint("두번째 채플 fetch 실패 : \(String(describing: error))")
                return .none
                
            case .fetchCurrentSemesterGradeResponse(.success(let lectures)):
                state.currentSemesterLectures = lectures
                state.isLoading = false
                return .none
            case .fetchCurrentSemesterGradeResponse(.failure(let error)):
                state.toastMessage = String(describing: error)
                state.isLoading = false
                return .none
            case .openGiftLinkPressed:
                return handleGiftLinkPressed(&state)
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
    
    private func fetchChapelData() async throws -> ChapelCard {
        try await chapelClient.deleteChapelCard()
        let chapelCard = try await chapelClient.fetchChapelCard()
        try await chapelClient.updateChapelCard(chapelCard)
        return chapelCard
    }

    //MARK: - Events

    private func handleGiftLinkPressed(_ state: inout State) -> Effect<Action> {
        let student = state.studentInfo

        guard let saintID = StudentClient.keychain["saintID"] else {
            state.toastMessage = "학번을 불러올 수 없습니다."
            return .none
        }

        let baseURL = "https://lottery-one.vercel.app"

        let major = student.major.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let name = student.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let schoolNumber = saintID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let fullURLString = "\(baseURL)?major=\(major)&name=\(name)&schoolNumber=\(schoolNumber)"

        guard let url = URL(string: fullURLString) else {
            state.toastMessage = "복권 페이지 링크를 열 수 없습니다."
            return .none
        }

        state.path.append(.web(WebReducer.State(url: url)))
        return .none
    }

}
