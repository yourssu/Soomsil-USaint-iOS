//
//  UserDefaultManager.swift
//  Soomsil-USaint-iOS
//
//  Created by 이조은 on 12/18/24.
//

import Foundation
import UIKit
import UserNotifications

class LocalNotificationManager {
    static let shared = LocalNotificationManager()
    let defaults = UserDefaults.standard

    func saveNotificationPermission(_ permission: Bool) {
        defaults.set(permission, forKey: "permission")
    }

    func getNotificationPermission() -> Bool {
        return defaults.bool(forKey: "permission")
    }

    func saveIsFirst(_ first: Bool) {
        defaults.set(first, forKey: "isFirst")
    }

    func getIsFirst() -> Bool {
        return defaults.bool(forKey: "isFirst")
    }

    func removeAll() {
        defaults.removeObject(forKey: "permission")
        defaults.removeObject(forKey: "isFirst")
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
                if granted == true && error == nil {
                    self.saveNotificationPermission(true)
                    completion(true)
                } else {
                    self.saveNotificationPermission(false)
                    completion(false)
                }
            }
    }


    func check(completion: @escaping (Bool) -> Void) {
        let current = UNUserNotificationCenter.current()

        current.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional :
                completion(true)
            case .denied, .ephemeral, .notDetermined:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }

    func pushLectureNotification(lectureTitle: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "숨쉴때 유세인트"
        notificationContent.body = "[\(lectureTitle)] 과목의 성적이 공개되었어요."
        notificationContent.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: lectureTitle,
                                            content: notificationContent,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
}
