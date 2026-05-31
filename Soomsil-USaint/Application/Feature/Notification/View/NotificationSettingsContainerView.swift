//
//  NotificationSettingsContainerView.swift
//  Soomsil-USaint
//

import SwiftUI
import UIKit
import UserNotifications

import ComposableArchitecture

struct NotificationSettingsContainerView: View {
    let close: () -> Void

    @Dependency(\.localNotificationClient) private var localNotificationClient

    @AppStorage("permission") private var isPushNotificationEnabled = false
    @AppStorage("courseRegistrationNotificationEnabled") private var isCourseRegistrationEnabled = true
    @AppStorage("assignmentDeadlineNotificationEnabled") private var isAssignmentDeadlineEnabled = true
    @AppStorage("gradeAnnouncementNotificationEnabled") private var isGradeAnnouncementEnabled = true
    @AppStorage("chapelNotificationEnabled") private var isChapelEnabled = true
    @AppStorage("marketingNotificationEnabled") private var isMarketingEnabled = false

    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private var isSystemAuthorized: Bool {
        authorizationStatus == .authorized || authorizationStatus == .provisional
    }

    var body: some View {
        NotificationSettingsView(
            isSystemAuthorized: isSystemAuthorized,
            isPushNotificationEnabled: isPushNotificationEnabled && isSystemAuthorized,
            isCourseRegistrationEnabled: isCourseRegistrationEnabled,
            isAssignmentDeadlineEnabled: isAssignmentDeadlineEnabled,
            isGradeAnnouncementEnabled: isGradeAnnouncementEnabled,
            isChapelEnabled: isChapelEnabled,
            isMarketingEnabled: isMarketingEnabled,
            pushToggleChanged: updatePushNotification,
            courseRegistrationToggleChanged: {
                updateNotificationType(isOn: $0) {
                    isCourseRegistrationEnabled = $0
                }
            },
            assignmentDeadlineToggleChanged: {
                updateNotificationType(isOn: $0) {
                    isAssignmentDeadlineEnabled = $0
                }
            },
            gradeAnnouncementToggleChanged: {
                updateNotificationType(isOn: $0) {
                    isGradeAnnouncementEnabled = $0
                }
            },
            chapelToggleChanged: {
                updateNotificationType(isOn: $0) {
                    isChapelEnabled = $0
                }
            },
            marketingToggleChanged: {
                updateNotificationType(isOn: $0) {
                    isMarketingEnabled = $0
                }
            },
            sendTestNotification: sendTestNotification,
            close: close
        )
        .task {
            await refreshAuthorizationStatus()
        }
    }

    @MainActor
    private func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus

        if !isSystemAuthorized {
            isPushNotificationEnabled = false
        }
    }

    private func updatePushNotification(_ isOn: Bool) {
        guard isOn else {
            isPushNotificationEnabled = false
            return
        }

        switch authorizationStatus {
        case .authorized, .provisional:
            isPushNotificationEnabled = true
        case .notDetermined:
            requestAuthorization()
        case .denied, .ephemeral:
            openSystemSettings()
        @unknown default:
            openSystemSettings()
        }
    }

    private func updateNotificationType(isOn: Bool, assign: (Bool) -> Void) {
        guard isSystemAuthorized, isPushNotificationEnabled else {
            updatePushNotification(true)
            return
        }

        assign(isOn)
    }

    private func requestAuthorization() {
        Task {
            let granted = (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) ?? false

            await MainActor.run {
                isPushNotificationEnabled = granted
            }

            await refreshAuthorizationStatus()
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url)
        else { return }

        UIApplication.shared.open(url)
    }

    private func sendTestNotification() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                let granted = (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) ?? false

                await MainActor.run {
                    isPushNotificationEnabled = granted
                }

                guard granted else { return }
            } else if settings.authorizationStatus != .authorized && settings.authorizationStatus != .provisional {
                await MainActor.run {
                    openSystemSettings()
                }
                return
            } else {
                await MainActor.run {
                    isPushNotificationEnabled = true
                }
            }

            try? await localNotificationClient.setChapelPushNotification(
                ChapelCard(attendance: 4, seatPosition: "B-12", floorLevel: 1)
            )
            try? await localNotificationClient.setAssignmentDeadlinePushNotification("데이터베이스", 1)
            try? await localNotificationClient.setCourseRegistrationPushNotification(2)
            try? await localNotificationClient.setLecturePushNotification("데이터베이스")
        }
    }
}
