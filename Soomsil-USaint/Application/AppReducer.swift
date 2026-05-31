//
//  AppReducer.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import BackgroundTasks
import Foundation

import ComposableArchitecture
import Rusaint

@Reducer
struct AppReducer {
    @ObservableState
    enum State {
        case initial(SplashReducer.State)
        case loggedOut(LoginReducer.State)
        case loggedIn(MainTabReducer.State)
        
        init() {
            self = .initial(SplashReducer.State())
        }
    }
    
    enum Action {
        case backgroundTask
        case splash(SplashReducer.Action)
        case login(LoginReducer.Action)
        case mainTab(MainTabReducer.Action)
        case notificationOpened(USaintNotificationRoute)
    }
    
    @Dependency(\.gradeClient) var gradeClient
    @Dependency(\.localNotificationClient) var localNotificationClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .backgroundTask:
                scheduleBackgroundTask()
                return .run { send in
                    try await scheduleChangedGardeLecturePush()
                }
            case .splash(.initResponse(.success(let (studentInfo, totalReportCard, chapelCard)))):
                state = .loggedIn(MainTabReducer.State(studentInfo: studentInfo, totalReportCard: totalReportCard, chapelCard: chapelCard))
                return routePendingNotificationIfNeeded()
            case .splash(.initResponse(.failure)):
                state = .loggedOut(LoginReducer.State())
                return .none
            case .login(.loginResponse(.success(let (info, report, chapel)))):
                state = .loggedIn(MainTabReducer.State(studentInfo: info, totalReportCard: report, chapelCard: chapel))
                return routePendingNotificationIfNeeded()
            case .mainTab(.setting(.logoutCompleted)):
                state = .initial(SplashReducer.State())
                return .none
            case .notificationOpened(let route):
                guard case .loggedIn = state else {
                    return .none
                }
                return .send(.mainTab(.notificationOpened(route)))
            default:
                return .none
            }
        }
        .ifCaseLet(\.initial, action: \.splash) {
            SplashReducer()
        }
        .ifCaseLet(\.loggedOut, action: \.login) {
            LoginReducer()
        }
        .ifCaseLet(\.loggedIn, action: \.mainTab) {
            MainTabReducer()
        }
    }
    
    private func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "soomsilUSaint.com")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30*60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduler Scheduled")
        } catch(let error) {
            print("Scheduler Error: \(error)")
        }
    }
    
    private func scheduleChangedGardeLecturePush() async throws {
        guard let currentSemester = try await gradeClient.currentYearAndSemester() else {
            return
        }
        
        let grades = try await gradeClient.fetchGrades(
            year: currentSemester.year,
            semester: currentSemester.semester
        )
        guard !grades.isEmpty else {
            return
        }
        
        let currentGrade = GradeSummary(
            year: currentSemester.year,
            semester: currentSemester.semester.toString(),
            gpa: 0,
            earnedCredit: 0,
            semesterRank: 0,
            semesterStudentCount: 0,
            overallRank: 0,
            overallStudentCount: 0,
            lectures: grades.toLectureDetails()
        )
        
        guard let storedGrade = try await gradeClient.getGrades(
            year: currentSemester.year,
            semester: currentSemester.semester.toString()
        ) else {
            return
        }
        
        let difference = storedGrade.getDifferenceLectureTitleByGradeSummary(by: currentGrade)
        for diff in difference {
            try await localNotificationClient.setLecturePushNotification(diff)
            try await gradeClient.updateGrades(
                year: currentSemester.year,
                semester: currentSemester.semester.toString(),
                newLectures: grades.toLectureDetails()
            )
        }
    }

    private func routePendingNotificationIfNeeded() -> Effect<Action> {
        guard let routeValue = UserDefaults.standard.string(forKey: NotificationStorageKey.pendingRoute),
              let route = USaintNotificationRoute(rawValue: routeValue)
        else {
            return .none
        }

        UserDefaults.standard.removeObject(forKey: NotificationStorageKey.pendingRoute)
        return .send(.mainTab(.notificationOpened(route)))
    }
}
