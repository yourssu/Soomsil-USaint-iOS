//
//  NotificationRouting.swift
//  Soomsil-USaint
//

import Foundation

extension Notification.Name {
    static let usaintNotificationOpened = Notification.Name("usaintNotificationOpened")
}

enum NotificationUserInfoKey {
    static let route = "route"
    static let category = "category"
    static let title = "title"
    static let body = "body"
}

enum NotificationStorageKey {
    static let pendingRoute = "pendingNotificationRoute"
}

enum NotificationActionIdentifier {
    static let openChapelSeat = "OPEN_CHAPEL_SEAT"
    static let snoozeChapel = "SNOOZE_CHAPEL"
    static let openAssignment = "OPEN_ASSIGNMENT"
    static let snoozeAssignment = "SNOOZE_ASSIGNMENT"
    static let openGrade = "OPEN_GRADE"
}

extension USaintNotificationRoute {
    init?(remoteValue: String) {
        let normalizedValue = remoteValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        switch normalizedValue {
        case Self.notification.rawValue,
            "home",
            "feed",
            "course",
            "course_registration",
            "assignment",
            "assignment_deadline",
            "grade",
            "grade_announcement",
            "marketing",
            "알림",
            "성적",
            "과제",
            "수강신청":
            self = .notification
        case Self.chapel.rawValue,
            "채플":
            self = .chapel
        default:
            return nil
        }
    }

    init?(userInfo: [AnyHashable: Any]) {
        if let routeValue = userInfo[NotificationUserInfoKey.route] as? String,
           let route = USaintNotificationRoute(remoteValue: routeValue) {
            self = route
            return
        }

        if let category = USaintNotificationCategory(userInfo: userInfo) {
            self = category.defaultRoute
            return
        }

        return nil
    }
}
