//
//  Rusaint_iOSApp.swift
//  Rusaint-iOS
//
//  Created by 이조은 on 12/15/24.
//

import SwiftUI
import BackgroundTasks

@main
struct Rusaint_iOSApp: App {

    @Environment(\.scenePhase) var scenePhase
    let viewModel = DefaultSaintHomeViewModel()
    @State private var isLoggedIn: Bool = HomeRepository.shared.hasCachedUserInformation

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: viewModel, isLoggedIn: $isLoggedIn)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .background {
                        scheduleCurrentSemester()
                        notifyUpdateLecture()
                    }
                }
        }
        .backgroundTask(.appRefresh("soomsilUSaint.com")) {
            print("=== backgroundTask")
            scheduleCurrentSemester()
            notifyUpdateLecture()
        }
    }
}

func scheduleCurrentSemester() {
    print("=== scheduleCurrentSemester")
    let request = BGAppRefreshTaskRequest(identifier: "soomsilUSaint.com")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 30*60)

    do {
        try BGTaskScheduler.shared.submit(request)
        print("")
    } catch(let error) {
        print("Scheduler Error: \(error)")
    }
}

func notifyUpdateLecture() {
    print("=== notifyUpdateLecture")

    let lectureTitle = "창의융합인재되기3code전략"
    LocalNotificationManager.shared.pushNotification(title: "숨쉴때 유세인트", body: "[\(lectureTitle)] 과목의 성적이 공개되었어요.", identifier: "notifyUpdateLecture")
}
