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
        case loggedIn(HomeReducer.State)
        
        init() {
            self = .initial(SplashReducer.State())
        }
    }
    
    enum Action {
        case backgroundTask
        case splash(SplashReducer.Action)
        case login(LoginReducer.Action)
        case home(HomeReducer.Action)
    }
    
    @Dependency(\.gradeClient) var gradeClient
    @Dependency(\.localNotificationClient) var localNotificationClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .backgroundTask:
                scheduleCurrentSemester()
                return .run { send in
                    try await localNotificationClient.setLecturePushNotification("")
                }
            case .splash(.initResponse(.success(let (studentInfo, totalReportCard)))):
                state = .loggedIn(HomeReducer.State(studentInfo: studentInfo, totalReportCard: totalReportCard))
                return .none
            case .splash(.initResponse(.failure)):
                state = .loggedOut(LoginReducer.State())
                return .none
            case .login(.loginResponse(.success(let (info, report)))):
                state = .loggedIn(HomeReducer.State(studentInfo: info, totalReportCard: report))
                return .none
            case .home(.path(.element(id: _, action: .setting(.logoutCompleted)))):
                state = .loggedOut(LoginReducer.State())
                return .none
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
        .ifCaseLet(\.loggedIn, action: \.home) {
            HomeReducer()
        }
    }
    
    func scheduleCurrentSemester() {
        let request = BGAppRefreshTaskRequest(identifier: "soomsilUSaint.com")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30*60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduler Scheduled")
        } catch(let error) {
            print("Scheduler Error: \(error)")
        }
    }
    
    func compareAndFetchCurrentSemester() async throws {
        guard let currentSemester = try await gradeClient.currentYearAndSemester() else {
            return
        }
        
        let grades = try await gradeClient.fetchGrades(
            year: currentSemester.year,
            semester: currentSemester.semester
        )
        let currentGrade = GradeSummary(
            year: currentSemester.year,
            semester: semesterTypeToString(currentSemester.semester),
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
            semester: semesterTypeToString(currentSemester.semester)
        ) else {
            return
        }
        
        let difference = compareSemesters(storedGrade, currentGrade)
        for diff in difference {
            try await localNotificationClient.setLecturePushNotification(diff)
            try await gradeClient.updateGrades(
                year: currentSemester.year,
                semester: semesterTypeToString(currentSemester.semester),
                newLectures: grades.toLectureDetails()
            )
        }
    }
    
    private func compareSemesters(_ oldSemester: GradeSummary, _ newSemester: GradeSummary) -> [String] {
        let oldLectures = oldSemester.lectures?.reduce(into: [String: LectureDetail]()) { result, lecture in
            result[lecture.code] = lecture
        }
        let newLectures = newSemester.lectures?.reduce(into: [String: LectureDetail]()) { result, lecture in
            result[lecture.code] = lecture
        }
        var gradeChangedLectures: [String] = []
        
        if let newLectures = newLectures {
            for (code, newLecture) in newLectures {
                if let oldLecture = oldLectures?[code],
                   oldLecture.grade != newLecture.grade {
                    gradeChangedLectures.append(newLecture.title)
                }
            }
        }
        
        return gradeChangedLectures
    }
    
    private func semesterTypeToString(_ semesterType: SemesterType) -> String {
        switch semesterType {
        case .one:
            return "1 학기"
        case .two:
            return "2 학기"
        case .summer:
            return "여름학기"
        case .winter:
            return "겨울학기"
        }
    }
}
