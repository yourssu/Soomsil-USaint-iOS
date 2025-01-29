//
//  LocalNotificationClient.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import UIKit

import ComposableArchitecture

@DependencyClient
struct LocalNotificationClient {
    var requestPushAuthorization: @Sendable () async throws -> Bool
    var getPushAuthorizationStatus: @Sendable () async throws -> Bool
    var setLecturePushNotification: @Sendable (String) async throws -> Void
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
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        }, getPushAuthorizationStatus: {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            return (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional)
        }, setLecturePushNotification: { lectureTitle in
            let content = UNMutableNotificationContent()
            content.title = "숨쉴때 유세인트"
            content.body = "[\(lectureTitle)] 과목의 성적이 공개되었어요."
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            let request = UNNotificationRequest(identifier: lectureTitle, content: content, trigger: trigger)
            
            try await UNUserNotificationCenter.current().add(request)
        }
    )
    
    static let previewValue: LocalNotificationClient = Self(
        requestPushAuthorization: {
            return true
        }, getPushAuthorizationStatus: {
            return true
        }, setLecturePushNotification: { lectureTitle in
            debugPrint(lectureTitle)
        }
    )
    
    static let testValue: LocalNotificationClient = previewValue
}
