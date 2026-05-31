//
//  NotificationSettingsView.swift
//  Soomsil-USaint
//

import SwiftUI

struct NotificationSettingsView: View {
    let isSystemAuthorized: Bool
    let isPushNotificationEnabled: Bool
    let isCourseRegistrationEnabled: Bool
    let isAssignmentDeadlineEnabled: Bool
    let isGradeAnnouncementEnabled: Bool
    let isChapelEnabled: Bool
    let isMarketingEnabled: Bool
    let pushToggleChanged: (Bool) -> Void
    let courseRegistrationToggleChanged: (Bool) -> Void
    let assignmentDeadlineToggleChanged: (Bool) -> Void
    let gradeAnnouncementToggleChanged: (Bool) -> Void
    let chapelToggleChanged: (Bool) -> Void
    let marketingToggleChanged: (Bool) -> Void
    let sendTestNotification: () -> Void
    let close: () -> Void

    private var isNotificationTypeEnabled: Bool {
        isSystemAuthorized && isPushNotificationEnabled
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    sectionTitle(TextLiteral.NotificationSettingsView.receiveSectionTitle)

                    NotificationSettingRow(
                        title: TextLiteral.NotificationSettingsView.pushNotificationTitle,
                        subtitle: isSystemAuthorized
                            ? TextLiteral.NotificationSettingsView.pushNotificationSubtitle
                            : TextLiteral.NotificationSettingsView.pushNotificationDeniedSubtitle,
                        isOn: isPushNotificationEnabled,
                        isEnabled: true,
                        onChange: pushToggleChanged
                    )

                    sectionTitle(TextLiteral.NotificationSettingsView.typeSectionTitle)
                        .padding(.top, 32)

                    notificationTypeRows

                    sectionTitle(TextLiteral.NotificationSettingsView.marketingSectionTitle)
                        .padding(.top, 32)

                    NotificationSettingRow(
                        title: TextLiteral.NotificationSettingsView.marketingNotificationTitle,
                        subtitle: TextLiteral.NotificationSettingsView.marketingNotificationSubtitle,
                        isOn: isMarketingEnabled && isNotificationTypeEnabled,
                        isEnabled: isNotificationTypeEnabled,
                        onChange: marketingToggleChanged
                    )

#if DEBUG
                    debugSection
#endif
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 44)
            }
        }
        .background(.white)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button(action: close) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.gray950)
                    .frame(width: 28, height: 44)
            }
            .buttonStyle(.plain)

            Text(TextLiteral.NotificationSettingsView.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.gray950)

            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.slate100)
                .frame(height: 1)
        }
    }

    private var notificationTypeRows: some View {
        VStack(spacing: 0) {
            NotificationSettingRow(
                title: TextLiteral.NotificationSettingsView.courseRegistrationTitle,
                subtitle: TextLiteral.NotificationSettingsView.courseRegistrationSubtitle,
                isOn: isCourseRegistrationEnabled && isNotificationTypeEnabled,
                isEnabled: isNotificationTypeEnabled,
                onChange: courseRegistrationToggleChanged
            )

            divider

            NotificationSettingRow(
                title: TextLiteral.NotificationSettingsView.assignmentDeadlineTitle,
                subtitle: TextLiteral.NotificationSettingsView.assignmentDeadlineSubtitle,
                isOn: isAssignmentDeadlineEnabled && isNotificationTypeEnabled,
                isEnabled: isNotificationTypeEnabled,
                onChange: assignmentDeadlineToggleChanged
            )

            divider

            NotificationSettingRow(
                title: TextLiteral.NotificationSettingsView.gradeAnnouncementTitle,
                subtitle: TextLiteral.NotificationSettingsView.gradeAnnouncementSubtitle,
                isOn: isGradeAnnouncementEnabled && isNotificationTypeEnabled,
                isEnabled: isNotificationTypeEnabled,
                onChange: gradeAnnouncementToggleChanged
            )

            divider

            NotificationSettingRow(
                title: TextLiteral.NotificationSettingsView.chapelTitle,
                subtitle: TextLiteral.NotificationSettingsView.chapelSubtitle,
                isOn: isChapelEnabled && isNotificationTypeEnabled,
                isEnabled: isNotificationTypeEnabled,
                onChange: chapelToggleChanged
            )
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(.slate100)
            .frame(height: 1)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.slate400)
            .padding(.bottom, 16)
    }

#if DEBUG
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle(TextLiteral.NotificationSettingsView.debugSectionTitle)

            Button(action: sendTestNotification) {
                Text(TextLiteral.NotificationSettingsView.debugSendTestNotificationTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(isNotificationTypeEnabled ? .blue600 : .slate300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(!isNotificationTypeEnabled)

            Text(TextLiteral.NotificationSettingsView.debugSendTestNotificationSubtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.slate400)
        }
        .padding(.top, 32)
    }
#endif
}

private struct NotificationSettingRow: View {
    let title: String
    let subtitle: String
    let isOn: Bool
    let isEnabled: Bool
    let onChange: (Bool) -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isEnabled ? .gray950 : .slate400)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.slate400)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { isOn },
                set: { onChange($0) }
            ))
            .labelsHidden()
            .tint(.blue600)
            .disabled(!isEnabled)
        }
        .frame(minHeight: 80)
    }
}

#Preview {
    NotificationSettingsView(
        isSystemAuthorized: true,
        isPushNotificationEnabled: true,
        isCourseRegistrationEnabled: true,
        isAssignmentDeadlineEnabled: true,
        isGradeAnnouncementEnabled: true,
        isChapelEnabled: true,
        isMarketingEnabled: false,
        pushToggleChanged: { _ in },
        courseRegistrationToggleChanged: { _ in },
        assignmentDeadlineToggleChanged: { _ in },
        gradeAnnouncementToggleChanged: { _ in },
        chapelToggleChanged: { _ in },
        marketingToggleChanged: { _ in },
        sendTestNotification: {},
        close: {}
    )
}
