//
//  NotificationView.swift
//  Soomsil-USaint
//

import SwiftUI

struct NotificationView: View {
    @State private var selectedCategory: NotificationCategory = .all
    @State private var hasUnreadNotifications = true
    @State private var showsSettings = false

    private var visibleSections: [NotificationSection] {
        let unreadSections = NotificationSampleData.sections.map { section in
            NotificationSection(
                title: section.title,
                notifications: section.notifications.map { notification in
                    NotificationItem(
                        title: notification.title,
                        subtitle: notification.subtitle,
                        time: notification.time,
                        badge: notification.badge,
                        category: notification.category,
                        isRead: hasUnreadNotifications ? notification.isRead : true
                    )
                }
            )
        }

        guard selectedCategory != .all else {
            return unreadSections
        }

        return unreadSections.compactMap { section in
            let notifications = section.notifications.filter { $0.category == selectedCategory }
            return notifications.isEmpty ? nil : NotificationSection(title: section.title, notifications: notifications)
        }
    }

    private var unreadCount: Int {
        guard hasUnreadNotifications else { return 0 }
        return NotificationSampleData.sections
            .flatMap(\.notifications)
            .filter { !$0.isRead }
            .count
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    summary
                    if unreadCount > 0 {
                        featuredNotice
                    }
                    categoryTabs
                    retentionBanner
                    if unreadCount > 0 {
                        notificationList
                    } else {
                        emptyState
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.adaptiveBackground)
        }
        .background(Color.adaptiveBackground)
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
                    hasUnreadNotifications = false
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

    private var featuredNotice: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(TextLiteral.NotificationView.featuredTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.adaptivePrimaryText)

                Text(TextLiteral.NotificationView.featuredSubtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.adaptiveSecondaryText)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.adaptiveSecondaryText)
                .frame(width: 16, height: 16)
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
                NotificationSectionView(section: section)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
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
                NotificationRowView(notification: notification)

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

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.system(size: 14, weight: notification.isRead ? .medium : .semibold))
                    .foregroundStyle(notification.isRead ? Color.adaptiveTertiaryText : Color.adaptivePrimaryText)
                    .lineLimit(1)

                if let subtitle = notification.subtitle {
                    HStack(spacing: 6) {
                        Text(subtitle)

                        if let time = notification.time {
                            Circle()
                                .fill(Color.adaptiveSecondaryText)
                                .frame(width: 3, height: 3)

                            Text(time)
                        }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(notification.isRead ? Color.adaptiveTertiaryText : Color.adaptiveSecondaryText)
                    .lineLimit(1)
                } else if let time = notification.time {
                    Text(time)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.adaptiveTertiaryText)
                }
            }

            Spacer(minLength: 12)

            if let badge = notification.badge {
                NotificationBadgeView(badge: badge)
            }
        }
        .padding(.vertical, 12)
        .opacity(notification.isRead ? 0.55 : 1)
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
    let id = UUID()
    let title: String
    let notifications: [NotificationItem]
}

private struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let time: String?
    let badge: NotificationBadge?
    let category: NotificationCategory
    let isRead: Bool
}

private struct NotificationBadge {
    let title: String
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color
    let hasBorder: Bool

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

private enum NotificationSampleData {
    static let sections: [NotificationSection] = [
        NotificationSection(
            title: "오늘",
            notifications: [
                NotificationItem(
                    title: "내 자리 - B-12",
                    subtitle: "채플 입장 시간 · 17:00 시작 · 입구 좌측으로 입장",
                    time: "5분 전",
                    badge: nil,
                    category: .classNotice,
                    isRead: false
                ),
                NotificationItem(
                    title: "데이터베이스 과제 마감 D-1",
                    subtitle: "오늘 자정 마감 · 아직 제출 전이에요",
                    time: "1시간 전",
                    badge: .urgent("D-1"),
                    category: .classNotice,
                    isRead: false
                ),
                NotificationItem(
                    title: "수강신청 알림",
                    subtitle: "2025-2학기 수강신청이 D-2 남았어요",
                    time: "2시간 전",
                    badge: nil,
                    category: .academic,
                    isRead: false
                )
            ]
        ),
        NotificationSection(
            title: "이번 주",
            notifications: [
                NotificationItem(
                    title: "비전채플 11회차",
                    subtitle: "내 자리 B-12",
                    time: "5/8 17:00",
                    badge: .neutral("내일"),
                    category: .classNotice,
                    isRead: false
                ),
                NotificationItem(
                    title: "데이터베이스 중간고사",
                    subtitle: "형남공학관 308호",
                    time: "5/20",
                    badge: .neutral("D-5"),
                    category: .classNotice,
                    isRead: false
                ),
                NotificationItem(
                    title: "운영체제 과제 2 안내",
                    subtitle: "5월 12일 마감",
                    time: "5/6",
                    badge: nil,
                    category: .classNotice,
                    isRead: false
                ),
                NotificationItem(
                    title: "학과 사무실 안내",
                    subtitle: "휴학 신청 마감 D-7",
                    time: "5/5",
                    badge: nil,
                    category: .academic,
                    isRead: false
                ),
                NotificationItem(
                    title: "성적장학금 신청 안내",
                    subtitle: "신청 기간 시작",
                    time: "5/4",
                    badge: nil,
                    category: .academic,
                    isRead: false
                )
            ]
        ),
        NotificationSection(
            title: "이전",
            notifications: [
                NotificationItem(
                    title: "3월 학사일정 안내",
                    subtitle: nil,
                    time: "3일 전",
                    badge: nil,
                    category: .academic,
                    isRead: true
                ),
                NotificationItem(
                    title: "전산 시스템 점검 안내",
                    subtitle: nil,
                    time: "4월 25일",
                    badge: nil,
                    category: .academic,
                    isRead: true
                )
            ]
        )
    ]
}

#Preview {
    NotificationView()
}
