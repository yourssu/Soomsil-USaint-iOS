//
//  RemoteNotificationClient.swift
//  Soomsil-USaint
//

import Foundation
import UIKit
import UserNotifications

import ComposableArchitecture
import FirebaseMessaging

struct RemoteNotificationClient {
    var registerDeviceIfAuthorized: @Sendable () async -> Void
    var syncTopicSubscriptions: @Sendable () async -> Void
    var updateTopicSubscription: @Sendable (USaintNotificationCategory, Bool) async -> Void
    var refreshRegistrationToken: @Sendable () async -> Void
    var handleRegistrationToken: @Sendable (String?) async -> Void
}

extension DependencyValues {
    var remoteNotificationClient: RemoteNotificationClient {
        get { self[RemoteNotificationClient.self] }
        set { self[RemoteNotificationClient.self] = newValue }
    }
}

extension RemoteNotificationClient: DependencyKey {
    static let liveValue: RemoteNotificationClient = {
        @Dependency(\.alarmBackendClient) var alarmBackendClient

        return Self(
            registerDeviceIfAuthorized: {
                await registerRemoteNotificationsIfAuthorized()
            },
            syncTopicSubscriptions: {
                await syncFCMTopicSubscriptions()
            },
            updateTopicSubscription: { category, isEnabled in
                UserDefaults.standard.set(isEnabled, forKey: category.userDefaultsKey)
                await syncFCMTopicSubscriptions()
            },
            refreshRegistrationToken: {
                await refreshFCMRegistrationToken()
            },
            handleRegistrationToken: { token in
                await handleFCMRegistrationToken(token)

                guard let token, !token.isEmpty else {
                    return
                }

                do {
                    try await alarmBackendClient.registerDevice(token)
                } catch {
                    debugPrint("Alarm backend device registration failed: \(error)")
                }
            }
        )
    }()

    static let previewValue: RemoteNotificationClient = Self(
        registerDeviceIfAuthorized: {},
        syncTopicSubscriptions: {},
        updateTopicSubscription: { _, _ in },
        refreshRegistrationToken: {},
        handleRegistrationToken: { _ in }
    )

    static let testValue: RemoteNotificationClient = previewValue
}

enum RemoteNotificationStorageKey {
    static let fcmToken = "fcmRegistrationToken"
}

@MainActor
private func registerRemoteNotificationsIfAuthorized() async {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
        await syncFCMTopicSubscriptions()
        return
    }

    UIApplication.shared.registerForRemoteNotifications()
    if Messaging.messaging().apnsToken != nil {
        await refreshFCMRegistrationToken()
        await syncFCMTopicSubscriptions()
    }
}

private func syncFCMTopicSubscriptions() async {
    guard await hasAPNSToken() else {
        return
    }

    let settings = await UNUserNotificationCenter.current().notificationSettings()
    let canReceivePush = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
        && USaintNotificationCategory.isPushEnabledInUserDefaults

    for category in USaintNotificationCategory.allCases {
        let shouldSubscribe = canReceivePush && category.isEnabledInUserDefaults
        await setFCMSubscription(shouldSubscribe, topic: category.fcmTopic)
    }
}

private func refreshFCMRegistrationToken() async {
    guard await hasAPNSToken() else {
        return
    }

    await withCheckedContinuation { continuation in
        Messaging.messaging().token { token, error in
            if let error {
                debugPrint("FCM registration token refresh failed: \(error)")
            }
            Task {
                await handleFCMRegistrationToken(token)
                continuation.resume()
            }
        }
    }
}

private func handleFCMRegistrationToken(_ token: String?) async {
    guard let token, !token.isEmpty else {
        return
    }

    UserDefaults.standard.set(token, forKey: RemoteNotificationStorageKey.fcmToken)
    await syncFCMTopicSubscriptions()
}

@MainActor
private func hasAPNSToken() -> Bool {
    Messaging.messaging().apnsToken != nil
}

private func setFCMSubscription(_ shouldSubscribe: Bool, topic: String) async {
    await withCheckedContinuation { continuation in
        let completion: @Sendable (Error?) -> Void = { error in
            if let error {
                debugPrint("FCM topic \(shouldSubscribe ? "subscribe" : "unsubscribe") failed: \(topic), \(error)")
            }
            continuation.resume()
        }

        if shouldSubscribe {
            Messaging.messaging().subscribe(toTopic: topic, completion: completion)
        } else {
            Messaging.messaging().unsubscribe(fromTopic: topic, completion: completion)
        }
    }
}
