//
//  LocalNotificationClient.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import UIKit

import ComposableArchitecture

struct LocalNotificationClient {
    // TODO: 논의가 필요한 부분 -> UserDefaults 대신 @Shared를 통해 permission과 isFirst를 사용하는 것이 어떤가요?
    // isFirst는 Home에서만 사용해서 옮기는 것도 가능하지만, permission은 Home, Setting, backgroundTask에서 사용하니까 일단 전역으로 두는게 좋을까요?
    
    var requestPushAuthorization: @Sendable () async throws -> Bool
    var getPushAuthorizationStatus: @Sendable () async -> Bool
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
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
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
    
    static let testValue: LocalNotificationClient = Self(
        requestPushAuthorization: {
            return true
        }, getPushAuthorizationStatus: {
            return true
        }, setLecturePushNotification: { lectureTitle in
            debugPrint(lectureTitle)
        }
    )
}
