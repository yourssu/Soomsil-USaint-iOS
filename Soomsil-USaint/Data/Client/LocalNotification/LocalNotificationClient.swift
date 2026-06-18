//
//  LocalNotificationClient.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import Foundation
import UIKit
import UserNotifications

import ComposableArchitecture

enum USaintNotificationCategory: String, CaseIterable, Sendable {
    case courseRegistration
    case assignmentDeadline
    case gradeAnnouncement
    case chapel
    case marketing

    var userDefaultsKey: String {
        switch self {
        case .courseRegistration:
            "courseRegistrationNotificationEnabled"
        case .assignmentDeadline:
            "assignmentDeadlineNotificationEnabled"
        case .gradeAnnouncement:
            "gradeAnnouncementNotificationEnabled"
        case .chapel:
            "chapelNotificationEnabled"
        case .marketing:
            "marketingNotificationEnabled"
        }
    }

    var defaultEnabled: Bool {
        switch self {
        case .marketing:
            false
        case .courseRegistration, .assignmentDeadline, .gradeAnnouncement, .chapel:
            true
        }
    }
}

extension USaintNotificationCategory {
    static var isPushEnabledInUserDefaults: Bool {
        if UserDefaults.standard.object(forKey: "permission") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "permission")
    }

    var isEnabledInUserDefaults: Bool {
        if UserDefaults.standard.object(forKey: userDefaultsKey) == nil {
            return defaultEnabled
        }
        return UserDefaults.standard.bool(forKey: userDefaultsKey)
    }

    var fcmTopic: String {
        switch self {
        case .courseRegistration:
            "usaint_course_registration"
        case .assignmentDeadline:
            "usaint_assignment_deadline"
        case .gradeAnnouncement:
            "usaint_grade_announcement"
        case .chapel:
            "usaint_chapel"
        case .marketing:
            "usaint_marketing"
        }
    }

    var defaultRoute: USaintNotificationRoute {
        switch self {
        case .chapel:
            .chapel
        case .courseRegistration, .assignmentDeadline, .gradeAnnouncement, .marketing:
            .notification
        }
    }

    init?(remoteValue: String) {
        let normalizedValue = remoteValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        switch normalizedValue {
        case Self.courseRegistration.rawValue.lowercased(),
            "course_registration",
            "course",
            "수강",
            "수강신청":
            self = .courseRegistration
        case Self.assignmentDeadline.rawValue.lowercased(),
            "assignment_deadline",
            "assignment",
            "assignments",
            "과제":
            self = .assignmentDeadline
        case Self.gradeAnnouncement.rawValue.lowercased(),
            "grade_announcement",
            "grade",
            "grades",
            "성적":
            self = .gradeAnnouncement
        case Self.chapel.rawValue.lowercased(),
            "채플":
            self = .chapel
        case Self.marketing.rawValue.lowercased(),
            "event",
            "events",
            "마케팅",
            "이벤트":
            self = .marketing
        default:
            return nil
        }
    }

    init?(userInfo: [AnyHashable: Any]) {
        for key in [
            NotificationUserInfoKey.category,
            "notification_category",
            "notificationCategory",
            "domain",
            "type"
        ] {
            if let value = userInfo[key] as? String,
               let category = USaintNotificationCategory(remoteValue: value) {
                self = category
                return
            }
        }
        return nil
    }
}

enum USaintNotificationRoute: String, Sendable {
    case notification
    case chapel
}

struct USaintNotificationPayload: Sendable {
    let identifier: String
    let title: String
    let body: String
    let category: USaintNotificationCategory
    let route: USaintNotificationRoute
    let timeInterval: TimeInterval

    static func gradeAnnouncement(lectureTitle: String) -> Self {
        Self(
            identifier: "grade-\(lectureTitle)",
            title: "\(lectureTitle) 성적 공개",
            body: "성적이 공개되었어요",
            category: .gradeAnnouncement,
            route: .notification,
            timeInterval: 2
        )
    }

    static func chapelEntrance(chapelCard: ChapelCard) -> Self {
        Self(
            identifier: "chapel-\(chapelCard.seatPosition)",
            title: "내 자리 - \(chapelCard.seatPosition)",
            body: "채플 입장 시간 · 17:00 시작 · 입구 좌측으로 입장",
            category: .chapel,
            route: .chapel,
            timeInterval: 2
        )
    }

    static func courseRegistration(daysRemaining: Int) -> Self {
        Self(
            identifier: "course-registration-d-\(daysRemaining)",
            title: "수강신청 알림",
            body: "2025-2학기 수강신청이 D-\(daysRemaining) 남았어요",
            category: .courseRegistration,
            route: .notification,
            timeInterval: 2
        )
    }

    static func assignmentDeadline(title: String, daysRemaining: Int) -> Self {
        Self(
            identifier: "assignment-\(title)-d-\(daysRemaining)",
            title: "\(title) 과제 마감 D-\(daysRemaining)",
            body: "오늘 자정 마감 · 아직 제출 전이에요",
            category: .assignmentDeadline,
            route: .notification,
            timeInterval: 2
        )
    }
}

struct LocalNotificationClient {
    var requestPushAuthorization: @Sendable () async throws -> Bool
    var getPushAuthorizationStatus: @Sendable () async -> Bool
    var scheduleNotification: @Sendable (USaintNotificationPayload) async throws -> Void
    var setLecturePushNotification: @Sendable (String) async throws -> Void
    var setChapelPushNotification: @Sendable (ChapelCard) async throws -> Void
    var setCourseRegistrationPushNotification: @Sendable (Int) async throws -> Void
    var setAssignmentDeadlinePushNotification: @Sendable (String, Int) async throws -> Void
}

extension DependencyValues {
    var localNotificationClient: LocalNotificationClient {
        get { self[LocalNotificationClient.self] }
        set { self[LocalNotificationClient.self] = newValue }
    }
}

extension LocalNotificationClient: DependencyKey {
    static let liveValue: LocalNotificationClient = Self(
        requestPushAuthorization: {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])

            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }

            return granted
        }, getPushAuthorizationStatus: {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            return (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional)
        }, scheduleNotification: { payload in
            try await scheduleLocalNotification(payload)
        }, setLecturePushNotification: { lectureTitle in
            try await scheduleLocalNotification(.gradeAnnouncement(lectureTitle: lectureTitle))
        }, setChapelPushNotification: { chapelCard in
            try await scheduleLocalNotification(.chapelEntrance(chapelCard: chapelCard))
        }, setCourseRegistrationPushNotification: { daysRemaining in
            try await scheduleLocalNotification(.courseRegistration(daysRemaining: daysRemaining))
        }, setAssignmentDeadlinePushNotification: { title, daysRemaining in
            try await scheduleLocalNotification(.assignmentDeadline(title: title, daysRemaining: daysRemaining))
        }
    )
    
    static let previewValue: LocalNotificationClient = Self(
        requestPushAuthorization: {
            return true
        }, getPushAuthorizationStatus: {
            return true
        }, scheduleNotification: { payload in
            debugPrint(payload)
        }, setLecturePushNotification: { lectureTitle in
            debugPrint(lectureTitle)
        }, setChapelPushNotification: { chapelCard in
            debugPrint(chapelCard)
        }, setCourseRegistrationPushNotification: { daysRemaining in
            debugPrint(daysRemaining)
        }, setAssignmentDeadlinePushNotification: { title, daysRemaining in
            debugPrint(title, daysRemaining)
        }
    )
    
    static let testValue: LocalNotificationClient = previewValue
}

private func scheduleLocalNotification(_ payload: USaintNotificationPayload) async throws {
    let settings = await UNUserNotificationCenter.current().notificationSettings()

    guard (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional),
          USaintNotificationCategory.isPushEnabledInUserDefaults,
          payload.category.isEnabledInUserDefaults else {
        return
    }

    let content = UNMutableNotificationContent()
    content.title = payload.title
    content.body = payload.body
    content.sound = .default
    content.categoryIdentifier = payload.category.rawValue
    content.threadIdentifier = payload.category.rawValue
    content.userInfo = [
        NotificationUserInfoKey.category: payload.category.rawValue,
        NotificationUserInfoKey.route: payload.route.rawValue,
        NotificationUserInfoKey.title: payload.title,
        NotificationUserInfoKey.body: payload.body
    ]

    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: payload.timeInterval,
        repeats: false
    )
    let request = UNNotificationRequest(
        identifier: payload.identifier,
        content: content,
        trigger: trigger
    )

    try await UNUserNotificationCenter.current().add(request)
}
