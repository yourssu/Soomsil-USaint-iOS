//
//  LocalNotificationClient.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import UIKit

import ComposableArchitecture

struct LocalNotificationClient {
    
}

extension DependencyValues {
    var localNotificationClient: LocalNotificationClient {
        get { self[LocalNotificationClient.self] }
        set { self[LocalNotificationClient.self] = newValue }
    }
}

extension LocalNotificationClient: DependencyKey {
    static let liveValue: LocalNotificationClient = Self()
    
    static let previewValue: LocalNotificationClient = Self()
    
    static let testValue: LocalNotificationClient = Self()
}
