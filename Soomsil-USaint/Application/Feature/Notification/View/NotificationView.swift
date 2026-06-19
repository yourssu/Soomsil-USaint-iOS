//
//  NotificationView.swift
//  Soomsil-USaint
//

import SwiftUI

struct NotificationView: View {
    @State private var selectedCategory: NotificationCategory = .all
    @State private var notifications: [USaintReceivedNotification] = []
    @State private var showsSettings = false

    private var visibleNotifications: [USaintReceivedNotification] {
        switch selectedCategory {
        case .all:
            notifications
        case .academic:
            notifications.filter { $0.notificationCategory == .academic }
        case .classNotice:
            notifications.filter { $0.notificationCategory == .classNotice }
        }
    }

    private var visibleSections: [NotificationSection] {
        Dictionary(grouping: visibleNotifications, by: \.sectionTitle)
            .map { title, notifications in
                NotificationSection(
                    title: title,
                    notifications: notifications
                        .sorted { $0.sentAt > $1.sentAt }
                        .map(NotificationItem.init)
                )
            }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    private var featuredNotification: USaintReceivedNotification? {
        notifications.first { !$0.isRead }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    summary
                    if let featuredNotification {
                        featuredNotice(featuredNotification)
                    }
                    categoryTabs
                    retentionBanner
                    if visibleNotifications.isEmpty {
                        emptyState
                    } else {
                        notificationList
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.adaptiveBackground)
        }
        .background(Color.adaptiveBackground)
        .task {
            await reloadNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: .usaintReceivedNotificationsDidChange)) { _ in
            notifications = USaintReceivedNotificationStore.load()
        }
        .fullScreenCover(isPresented: $showsSettings) {
            NotificationSettingsContainerView(
                close: {
                    showsSettings = false
                }
            )
        }
    }

    private var header: some View {
        HStack {
            Text(TextLiteral.NotificationView.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.adaptivePrimaryText)

            Spacer()

            Button {
                showsSettings = true
            } label: {
                Icon.alarmSetting
                    .resizable()
                    .frame(width: 22, height: 22)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(TextLiteral.NotificationSettingsView.title)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(TextLiteral.NotificationView.unreadTitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.adaptiveSecondaryText)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(unreadCount)")
                            .font(.system(size: 36, weight: .heavy))
                            .foregroundStyle(Color.adaptivePrimaryText)

                        Text(TextLiteral.NotificationView.countUnit)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.adaptivePrimaryText)
                    }
                }

                Spacer()

                Button {
                    notifications = USaintReceivedNotificationStore.markAllRead()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                        Text(TextLiteral.NotificationView.markAllReadButtonTitle)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(.blue600)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(unreadCount == 0)
                .opacity(unreadCount == 0 ? 0.45 : 1)
            }

            if unreadCount > 0 {
                Label(TextLiteral.NotificationView.unreadDescription, systemImage: "info.circle")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.adaptiveSecondaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, unreadCount > 0 ? 20 : 8)
    }

    private func featuredNotice(_ notification: USaintReceivedNotification) -> some View {
        Button {
            open(notification)
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(notification.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.adaptivePrimaryText)
                        .lineLimit(1)

                    Text(notification.body ?? notification.category ?? notification.domain ?? "")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.adaptiveSecondaryText)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.adaptiveSecondaryText)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.adaptiveSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.adaptiveBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .buttonStyle(.plain)
    }

    private var categoryTabs: some View {
        HStack(spacing: 28) {
            ForEach(NotificationCategory.allCases, id: \.self) { category in
                Button {
                    selectedCategory = category
                } label: {
                    VStack(spacing: 8) {
                        Text(category.title)
                            .font(.system(size: 14, weight: selectedCategory == category ? .semibold : .medium))
                            .foregroundStyle(selectedCategory == category ? Color.adaptivePrimaryText : Color.adaptiveSecondaryText)

                        Capsule()
                            .fill(selectedCategory == category ? Color.adaptivePrimaryText : Color.clear)
                            .frame(width: selectedCategory == category ? 32 : 24, height: 2)
                    }
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.adaptiveBorder)
                .frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.adaptiveBorder)
                .frame(height: 1)
        }
    }

    private var retentionBanner: some View {
        Label(TextLiteral.NotificationView.retentionNotice, systemImage: "info.circle")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.adaptiveSecondaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.adaptiveSurface)
    }

    private var notificationList: some View {
        VStack(spacing: 0) {
            ForEach(visibleSections) { section in
                NotificationSectionView(section: section, open: open)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func reloadNotifications() async {
        notifications = await USaintReceivedNotificationStore.mergeDeliveredNotifications()
    }

    private func open(_ notification: USaintReceivedNotification) {
        notifications = USaintReceivedNotificationStore.markRead(notification.id)

        guard let route = notification.notificationRoute else {
            return
        }

        NotificationCenter.default.post(
            name: .usaintNotificationOpened,
            object: nil,
            userInfo: [NotificationUserInfoKey.route: route.rawValue]
        )
    }
}

private extension NotificationView {
    var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.adaptiveMutedSurface)
                    .frame(width: 76, height: 76)

                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray200)
                    .frame(width: 32, height: 32)
            }

            VStack(spacing: 10) {
                Text("아직 받은 알림이 없어요")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.adaptivePrimaryText)

                Text("새로운 학사 소식이 도착하면\n여기서 바로 알려드릴게요")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.adaptiveSecondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button {
                showsSettings = true
            } label: {
                Text("알림 받기 설정하기")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.adaptivePrimaryText)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color.adaptiveMutedSurface)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 128)
    }
}

private struct NotificationSectionView: View {
    let section: NotificationSection
    let open: (USaintReceivedNotification) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(section.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.adaptiveSecondaryText)

                Text("  ·  \(section.notifications.count)건")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.adaptiveTertiaryText)

                Spacer()
            }
            .padding(.top, 12)
            .padding(.bottom, 8)

            ForEach(Array(section.notifications.enumerated()), id: \.element.id) { index, notification in
                NotificationRowView(notification: notification) {
                    open(notification.rawNotification)
                }

                if index < section.notifications.count - 1 {
                    Divider()
                        .foregroundStyle(Color.adaptiveBorder)
                }
            }
        }
    }
}

private struct NotificationRowView: View {
    let notification: NotificationItem
    let open: () -> Void

    var body: some View {
        Button(action: open) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(notification.title)
                        .font(.system(size: 14, weight: notification.isRead ? .medium : .semibold))
                        .foregroundStyle(notification.isRead ? Color.adaptiveTertiaryText : Color.adaptivePrimaryText)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        if let subtitle = notification.subtitle {
                            Text(subtitle)
                        }

                        if notification.subtitle != nil {
                            Circle()
                                .fill(Color.adaptiveSecondaryText)
                                .frame(width: 3, height: 3)
                        }

                        Text(notification.time)
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(notification.isRead ? Color.adaptiveTertiaryText : Color.adaptiveSecondaryText)
                    .lineLimit(1)
                }

                Spacer(minLength: 12)

                if let badge = notification.badge {
                    NotificationBadgeView(badge: badge)
                }
            }
            .padding(.vertical, 12)
            .opacity(notification.isRead ? 0.55 : 1)
        }
        .buttonStyle(.plain)
    }
}

private struct NotificationBadgeView: View {
    let badge: NotificationBadge

    var body: some View {
        Text(badge.title)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(badge.foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badge.backgroundColor)
            .overlay(
                Capsule()
                    .stroke(badge.borderColor, lineWidth: badge.hasBorder ? 1 : 0)
            )
            .clipShape(Capsule())
    }
}

private enum NotificationCategory: CaseIterable {
    case all
    case academic
    case classNotice

    var title: String {
        switch self {
        case .all:
            TextLiteral.NotificationView.allTabTitle
        case .academic:
            TextLiteral.NotificationView.academicTabTitle
        case .classNotice:
            TextLiteral.NotificationView.classTabTitle
        }
    }
}

private struct NotificationSection: Identifiable {
    let title: String
    let notifications: [NotificationItem]

    var id: String { title }

    var sortOrder: Int {
        switch title {
        case "오늘":
            0
        case "이번 주":
            1
        default:
            2
        }
    }
}

private struct NotificationItem: Identifiable {
    let rawNotification: USaintReceivedNotification
    let title: String
    let subtitle: String?
    let time: String
    let badge: NotificationBadge?
    let isRead: Bool

    var id: String { rawNotification.id }

    init(_ notification: USaintReceivedNotification) {
        rawNotification = notification
        title = notification.title
        subtitle = notification.subtitle
        time = notification.sentAt.relativeNotificationTimeText
        badge = NotificationBadge(notification)
        isRead = notification.isRead
    }
}

private struct NotificationBadge {
    let title: String
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color
    let hasBorder: Bool

    init(
        title: String,
        foregroundColor: Color,
        backgroundColor: Color,
        borderColor: Color,
        hasBorder: Bool
    ) {
        self.title = title
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.hasBorder = hasBorder
    }

    init?(_ notification: USaintReceivedNotification) {
        if let priority = notification.priority, !priority.isEmpty {
            switch priority {
            case "P0":
                self = .urgent(priority)
            case "P1":
                self = .warning(priority)
            default:
                self = .neutral(priority)
            }
            return
        }

        guard let pushType = notification.pushType, !pushType.isEmpty else {
            return nil
        }

        if pushType.contains("이머전시") {
            self = .urgent("긴급")
        } else if pushType.contains("경고") {
            self = .warning("경고")
        } else if pushType.contains("미발송") {
            self = .neutral("차단")
        } else {
            self = .neutral("안내")
        }
    }

    static func urgent(_ title: String) -> Self {
        Self(
            title: title,
            foregroundColor: .error,
            backgroundColor: .error.opacity(0.1),
            borderColor: .clear,
            hasBorder: false
        )
    }

    static func warning(_ title: String) -> Self {
        Self(
            title: title,
            foregroundColor: .orange500,
            backgroundColor: .orange50,
            borderColor: .clear,
            hasBorder: false
        )
    }

    static func neutral(_ title: String) -> Self {
        Self(
            title: title,
            foregroundColor: .slate500,
            backgroundColor: .gray25,
            borderColor: .gray150,
            hasBorder: true
        )
    }
}

private extension USaintReceivedNotification {
    var notificationCategory: NotificationCategory {
        switch domain {
        case "과제", "시간표", "채플", "강의자료", "출석경고70", "출석경고75", "출석F확정":
            .classNotice
        default:
            .academic
        }
    }

    var notificationRoute: USaintNotificationRoute? {
        if let route,
           let notificationRoute = USaintNotificationRoute(rawValue: route) {
            return notificationRoute
        }

        if domain == "성적" || category?.contains("성적") == true {
            return .currentSemesterGrades
        }

        return .notification
    }

    var subtitle: String? {
        if let body, !body.isEmpty {
            return body
        }

        return [domain, category]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
            .nilIfEmpty
    }

    var sectionTitle: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(sentAt) {
            return "오늘"
        }

        if let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: sentAt), to: calendar.startOfDay(for: Date())).day,
           days < 7 {
            return "이번 주"
        }

        return "이전"
    }
}

private extension Date {
    var relativeNotificationTimeText: String {
        let interval = max(0, Date().timeIntervalSince(self))
        if interval < 60 {
            return "방금"
        }

        if interval < 60 * 60 {
            return "\(Int(interval / 60))분 전"
        }

        if interval < 24 * 60 * 60 {
            return "\(Int(interval / 60 / 60))시간 전"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M/d HH:mm"
        return formatter.string(from: self)
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

#Preview {
    NotificationView()
}
