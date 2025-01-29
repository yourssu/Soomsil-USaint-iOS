//
//  Rusaint_iOSApp.swift
//  Rusaint-iOS
//
//  Created by 이조은 on 12/15/24.
//

import SwiftUI
import BackgroundTasks

import ComposableArchitecture
import Rusaint

@main
struct Rusaint_iOSApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    let store = Store(initialState: AppReducer.State()) { AppReducer() }
    
    var body: some Scene {
        WindowGroup {
//            HomeView(viewModel: viewModel, isLoggedIn: $isLoggedIn)
//                .onChange(of: scenePhase) { newPhase in
//                    notificationPermission = LocalNotificationManager.shared.getNotificationPermission()
//                    if newPhase == .background && notificationPermission {
//                        scheduleCurrentSemester()
//                        Task {
//                            await compareAndFetchCurrentSemester()
//                        }
//                    }
//                }
            AppView(store: store)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    debugPrint("ScenePhase: \(oldPhase) to \(newPhase)")
                    if newPhase == .background {
                        scheduleCurrentSemester()
                    }
                }
        }
        .backgroundTask(.appRefresh("soomsilUSaint.com")) {
            await store.send(.backgroundTask)
        }
//        .backgroundTask(.appRefresh("soomsilUSaint.com")) {
//            notificationPermission = LocalNotificationManager.shared.getNotificationPermission()
//            if await notificationPermission {
//                scheduleCurrentSemester()
//                await compareAndFetchCurrentSemester()
//            }
//        }
    }
}

/**
 2024년 2학기를 불러와서 기존 Core Data랑 비교하는 함수
 */
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

public func compareAndFetchCurrentSemester() async {
    do {
        let existingSemester = SemesterRepository.shared.getSemester(year: 2024, semester: "2 학기")

//        print("=== 🌟🌟🌟\(String(describing: existingSemester))")
//        print()

        let userInfo = HomeRepository.shared.getUserLoginInformation()
        let session = try await USaintSessionBuilder().withPassword(id: userInfo[0], password: userInfo[1])
        if session != nil {
            let response = try await CourseGradesApplicationBuilder().build(session: session).classes(courseType: .bachelor,
                                                                                                            year: 2024,
                                                                                                            semester: .two,
                                                                                                            includeDetails: false)


            let currentClassesData = response.toLectureDetails()
            let currentSemester = GradeSummary(year: 2024,
                                                    semester: "2 학기",
                                                    gpa: 0,
                                                    earnedCredit: 0,
                                                    semesterRank: 0,
                                                    semesterStudentCount: 0,
                                                    overallRank: 0,
                                                    overallStudentCount: 0,
                                                    lectures: currentClassesData)

            if let existingSemester = existingSemester {
                let differences = compareSemesters(existingSemester, currentSemester)
//                print("=== ❌❌❌ Differences:", differences)
//                print()

                if !differences.isEmpty {
                    for i in 0...differences.count-1 {
                        LocalNotificationManager.shared.pushLectureNotification(lectureTitle: differences[i])
                    }
                    SemesterRepository.shared.updateLecturesForSemester(year: 2024, semester: "2 학기", newLectures: currentClassesData)
                }
            } else {
                print("No existing semester found.")
            }
        }
    } catch {
        print(" Compare And Fetch Current Semester Error: \(error)")
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

    if let newLectures = newLectures { // 먼저 newLectures를 언랩
        for (code, newLecture) in newLectures {
            if let oldLecture = oldLectures?[code],
               oldLecture.grade != newLecture.grade {
                gradeChangedLectures.append(newLecture.title)
            }
        }
    }

    return gradeChangedLectures
}
