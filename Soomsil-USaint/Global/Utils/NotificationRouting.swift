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
