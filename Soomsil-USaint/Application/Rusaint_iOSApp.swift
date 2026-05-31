//
//  Rusaint_iOSApp.swift
//  Rusaint-iOS
//
//  Created by 이조은 on 12/15/24.
//

import SwiftUI
import BackgroundTasks
import UserNotifications

import ComposableArchitecture
import FirebaseCore
import Rusaint
import Mixpanel

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        registerNotificationCategories()
        if let token = Bundle.main.object(forInfoDictionaryKey: "MIXPANEL_TEAM_TOKEN") as? String {
            Mixpanel.initialize(token: "4cb8a3b1aabf9715a4db3005904a744d", trackAutomaticEvents: false)
        } else {
            assertionFailure("Mixpanel 토큰을 불러올 수 없습니다.")
        }
        return true
    }

    private func registerNotificationCategories() {
        let chapelCategory = UNNotificationCategory(
            identifier: USaintNotificationCategory.chapel.rawValue,
            actions: [
                UNNotificationAction(
                    identifier: NotificationActionIdentifier.openChapelSeat,
                    title: "내 자리 보기",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: NotificationActionIdentifier.snoozeChapel,
                    title: "15분 후 다시 알림",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: []
        )

        let assignmentCategory = UNNotificationCategory(
            identifier: USaintNotificationCategory.assignmentDeadline.rawValue,
            actions: [
                UNNotificationAction(
                    identifier: NotificationActionIdentifier.openAssignment,
                    title: "과제 자세히 보기",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: NotificationActionIdentifier.snoozeAssignment,
                    title: "내일 다시 알림 받기",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: []
        )

        let gradeCategory = UNNotificationCategory(
            identifier: USaintNotificationCategory.gradeAnnouncement.rawValue,
            actions: [
                UNNotificationAction(
                    identifier: NotificationActionIdentifier.openGrade,
                    title: "성적표 자세히 보기",
                    options: [.foreground]
                )
            ],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            chapelCategory,
            assignmentCategory,
            gradeCategory
        ])
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        switch response.actionIdentifier {
        case NotificationActionIdentifier.snoozeChapel:
            await scheduleSnoozedNotification(from: response, seconds: 15 * 60)
            return
        case NotificationActionIdentifier.snoozeAssignment:
            await scheduleSnoozedNotification(from: response, seconds: 24 * 60 * 60)
            return
        default:
            break
        }

        if let route = response.notification.request.content.userInfo[NotificationUserInfoKey.route] as? String {
            UserDefaults.standard.set(route, forKey: NotificationStorageKey.pendingRoute)
        }

        NotificationCenter.default.post(
            name: .usaintNotificationOpened,
            object: nil,
            userInfo: response.notification.request.content.userInfo
        )
    }

    private func scheduleSnoozedNotification(
        from response: UNNotificationResponse,
        seconds: TimeInterval
    ) async {
        let originalContent = response.notification.request.content
        let content = UNMutableNotificationContent()
        content.title = originalContent.userInfo[NotificationUserInfoKey.title] as? String ?? originalContent.title
        content.body = originalContent.userInfo[NotificationUserInfoKey.body] as? String ?? originalContent.body
        content.sound = .default
        content.categoryIdentifier = originalContent.categoryIdentifier
        content.threadIdentifier = originalContent.threadIdentifier
        content.userInfo = originalContent.userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(response.notification.request.identifier)-snooze-\(Int(Date().timeIntervalSince1970))",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}

@main
struct Rusaint_iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @Environment(\.scenePhase) var scenePhase
    
    let store = Store(initialState: AppReducer.State()) { AppReducer() }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .onChange(of: scenePhase) { _, phase in
                    debugPrint("ScenePhase: \(phase)")
                    if phase == .background {
                        store.send(.backgroundTask)
                    }
                }
        }
        .backgroundTask(.appRefresh("soomsilUSaint.com")) {
            await store.send(.backgroundTask)
        }
    }
}
