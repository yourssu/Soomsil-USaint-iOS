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

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
                if granted == true && error == nil {
                    print("알림 권한이 허용되었습니다.")
                    self.saveNotificationPermission(true)
                    completion(true)
                } else {
                    print("알림 권한이 거부되었습니다.")
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
}
