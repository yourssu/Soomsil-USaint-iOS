//
//  ReceivedNotificationStore.swift
//  Soomsil-USaint
//

import Foundation
import UserNotifications

extension Notification.Name {
    static let usaintReceivedNotificationsDidChange = Notification.Name("usaintReceivedNotificationsDidChange")
}

struct USaintReceivedNotification: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let templateId: String?
    let domain: String?
    let category: String?
    let pushType: String?
    let priority: String?
    let title: String
    let body: String?
    let sentAt: Date
    let route: String?
    var isRead: Bool

    init?(
        notification: UNNotification,
        isRead: Bool = false
    ) {
        self.init(
            userInfo: notification.request.content.userInfo,
            title: notification.request.content.title,
            body: notification.request.content.body,
            fallbackIdentifier: notification.request.identifier,
            sentAt: notification.date,
            isRead: isRead
        )
    }

    init?(
        userInfo: [AnyHashable: Any],
        title fallbackTitle: String? = nil,
        body fallbackBody: String? = nil,
        fallbackIdentifier: String? = nil,
        sentAt fallbackDate: Date = Date(),
        isRead: Bool = false
    ) {
        let payloadTitle = Self.stringValue(
            for: ["title", NotificationUserInfoKey.title, "notificationTitle"],
            in: userInfo
        ) ?? Self.apsAlertValue("title", in: userInfo) ?? fallbackTitle

        let payloadBody = Self.stringValue(
            for: ["body", NotificationUserInfoKey.body, "message", "notificationBody"],
            in: userInfo
        ) ?? Self.apsAlertValue("body", in: userInfo) ?? fallbackBody

        let title = payloadTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let body = payloadBody?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty || !(body ?? "").isEmpty else {
            return nil
        }

        let templateId = Self.stringValue(
            for: ["templateId", "template_id", "id"],
            in: userInfo
        )
        let sentAt = Self.dateValue(for: ["sentAt", "sent_at", "createdAt", "created_at"], in: userInfo) ?? fallbackDate
        let domain = Self.stringValue(for: ["domain"], in: userInfo)
        let category = Self.stringValue(
            for: [NotificationUserInfoKey.category, "notification_category", "notificationCategory", "category", "type"],
            in: userInfo
        )
        let route = Self.normalizedRoute(in: userInfo, domain: domain, category: category)
        let notificationId = Self.stringValue(
            for: ["notificationId", "notification_id", "messageId", "message_id", "gcm.message_id"],
            in: userInfo
        )
        let id = notificationId
            ?? Self.fallbackIdentifier(
                templateId: templateId,
                title: title,
                body: body,
                sentAt: sentAt
            )

        self.id = id
        self.templateId = templateId
        self.domain = domain
        self.category = category
        self.pushType = Self.stringValue(for: ["pushType", "push_type"], in: userInfo)
        self.priority = Self.stringValue(for: ["priority"], in: userInfo)
        self.title = title.isEmpty ? (body ?? "") : title
        self.body = body?.isEmpty == true ? nil : body
        self.sentAt = sentAt
        self.route = route
        self.isRead = isRead
    }
}

enum USaintReceivedNotificationStore {
    private static let storageKey = "usaintReceivedNotifications"
    private static let retentionInterval: TimeInterval = 14 * 24 * 60 * 60
    private static let maxStoredCount = 200

    static func load() -> [USaintReceivedNotification] {
        let notifications = normalized(loadRaw())
        saveRaw(notifications)
        return notifications
    }

    @discardableResult
    static func upsert(_ notification: USaintReceivedNotification) -> [USaintReceivedNotification] {
        upsert([notification])
    }

    @discardableResult
    static func upsert(_ notifications: [USaintReceivedNotification]) -> [USaintReceivedNotification] {
        guard !notifications.isEmpty else {
            return load()
        }

        var stored = loadRaw()
        for notification in notifications {
            if let index = stored.firstIndex(where: { $0.id == notification.id }) {
                let wasRead = stored[index].isRead
                var merged = notification
                merged.isRead = wasRead || notification.isRead
                stored[index] = merged
            } else {
                stored.append(notification)
            }
        }

        let notifications = normalized(stored)
        saveRaw(notifications)
        NotificationCenter.default.post(name: .usaintReceivedNotificationsDidChange, object: nil)
        return notifications
    }

    static func markRead(_ id: String) -> [USaintReceivedNotification] {
        var notifications = loadRaw()
        guard let index = notifications.firstIndex(where: { $0.id == id }) else {
            return load()
        }

        notifications[index].isRead = true
        notifications = normalized(notifications)
        saveRaw(notifications)
        NotificationCenter.default.post(name: .usaintReceivedNotificationsDidChange, object: nil)
        return notifications
    }

    static func markAllRead() -> [USaintReceivedNotification] {
        let notifications = normalized(loadRaw().map { notification in
            var notification = notification
            notification.isRead = true
            return notification
        })
        saveRaw(notifications)
        NotificationCenter.default.post(name: .usaintReceivedNotificationsDidChange, object: nil)
        return notifications
    }

    static func store(_ notification: UNNotification, isRead: Bool = false) {
        guard let receivedNotification = USaintReceivedNotification(notification: notification, isRead: isRead) else {
            return
        }
        upsert(receivedNotification)
    }

    static func store(
        userInfo: [AnyHashable: Any],
        title: String? = nil,
        body: String? = nil,
        fallbackIdentifier: String? = nil,
        sentAt: Date = Date(),
        isRead: Bool = false
    ) {
        guard let notification = USaintReceivedNotification(
            userInfo: userInfo,
            title: title,
            body: body,
            fallbackIdentifier: fallbackIdentifier,
            sentAt: sentAt,
            isRead: isRead
        ) else {
            return
        }
        upsert(notification)
    }

    static func mergeDeliveredNotifications() async -> [USaintReceivedNotification] {
        let deliveredNotifications = await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                continuation.resume(returning: notifications)
            }
        }

        let notifications = deliveredNotifications.compactMap {
            USaintReceivedNotification(notification: $0)
        }

        return upsert(notifications)
    }

    private static func loadRaw() -> [USaintReceivedNotification] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }

        do {
            return try JSONDecoder().decode([USaintReceivedNotification].self, from: data)
        } catch {
            debugPrint("Received notification decode failed: \(error)")
            return []
        }
    }

    private static func saveRaw(_ notifications: [USaintReceivedNotification]) {
        do {
            let data = try JSONEncoder().encode(notifications)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            debugPrint("Received notification encode failed: \(error)")
        }
    }

    private static func normalized(_ notifications: [USaintReceivedNotification]) -> [USaintReceivedNotification] {
        let cutoffDate = Date().addingTimeInterval(-retentionInterval)
        return notifications
            .filter { $0.sentAt >= cutoffDate }
            .sorted { $0.sentAt > $1.sentAt }
            .prefix(maxStoredCount)
            .map { $0 }
    }
}

private extension USaintReceivedNotification {
    static func stringValue(for keys: [String], in userInfo: [AnyHashable: Any]) -> String? {
        for key in keys {
            guard let value = userInfo[AnyHashable(key)] else {
                continue
            }

            if let string = value as? String {
                let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedString.isEmpty {
                    return trimmedString
                }
            }

            if let number = value as? NSNumber {
                return number.stringValue
            }
        }
        return nil
    }

    static func apsAlertValue(_ key: String, in userInfo: [AnyHashable: Any]) -> String? {
        guard let aps = dictionaryValue(userInfo[AnyHashable("aps")]) else {
            return nil
        }

        if let alert = dictionaryValue(aps["alert"]),
           let value = alert[key] as? String,
           !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return value
        }

        if key == "body",
           let value = aps["alert"] as? String,
           !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return value
        }

        return nil
    }

    static func dateValue(for keys: [String], in userInfo: [AnyHashable: Any]) -> Date? {
        for key in keys {
            guard let value = userInfo[AnyHashable(key)] else {
                continue
            }

            if let date = value as? Date {
                return date
            }

            if let timeInterval = value as? TimeInterval {
                return Date(timeIntervalSince1970: normalizedTimeInterval(timeInterval))
            }

            if let number = value as? NSNumber {
                return Date(timeIntervalSince1970: normalizedTimeInterval(number.doubleValue))
            }

            if let string = value as? String {
                if let date = iso8601Date(from: string) {
                    return date
                }

                if let timeInterval = TimeInterval(string) {
                    return Date(timeIntervalSince1970: normalizedTimeInterval(timeInterval))
                }
            }
        }
        return nil
    }

    static func dictionaryValue(_ value: Any?) -> [String: Any]? {
        if let dictionary = value as? [String: Any] {
            return dictionary
        }

        if let dictionary = value as? [AnyHashable: Any] {
            return dictionary.reduce(into: [String: Any]()) { result, element in
                guard let key = element.key as? String else {
                    return
                }
                result[key] = element.value
            }
        }

        return nil
    }

    static func normalizedTimeInterval(_ timeInterval: TimeInterval) -> TimeInterval {
        timeInterval > 10_000_000_000 ? timeInterval / 1_000 : timeInterval
    }

    static func normalizedRoute(
        in userInfo: [AnyHashable: Any],
        domain: String?,
        category: String?
    ) -> String? {
        if let routeValue = stringValue(for: [NotificationUserInfoKey.route, "deeplink", "deepLink"], in: userInfo),
           let route = USaintNotificationRoute(remoteValue: routeValue) {
            return route.rawValue
        }

        if domain == "성적" || category?.contains("성적") == true {
            return USaintNotificationRoute.currentSemesterGrades.rawValue
        }

        return USaintNotificationRoute.notification.rawValue
    }

    static func fallbackIdentifier(
        templateId: String?,
        title: String,
        body: String?,
        sentAt: Date
    ) -> String {
        [
            templateId,
            title,
            body,
            String(Int(sentAt.timeIntervalSince1970))
        ]
            .compactMap { $0 }
            .joined(separator: "|")
    }

    static func iso8601Date(from string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
}
