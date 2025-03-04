//
//  RemoteConfigClient.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 2/18/25.
//

import Foundation

import ComposableArchitecture
import FirebaseRemoteConfig

@DependencyClient
struct RemoteConfigClient {
    private static let minimumVersionkey: String = "min_version_ios"
    
    var getMinimumVersion: @Sendable () async throws -> String
}

extension DependencyValues {
    var remoteConfigClient: RemoteConfigClient {
        get { self[RemoteConfigClient.self] }
        set { self[RemoteConfigClient.self] = newValue }
    }
}

extension RemoteConfigClient: DependencyKey {
    static let liveValue: RemoteConfigClient = Self(
        getMinimumVersion: {
            let remoteConfig = RemoteConfig.remoteConfig()
            try await remoteConfig.fetchAndActivate()
            
            let minimumVersion = remoteConfig[minimumVersionkey].stringValue
            return minimumVersion
        }
    )
    
    static let previewValue: RemoteConfigClient = Self(
        getMinimumVersion: {
            return "3.0.3"
        }
    )
    
    static let testValue: RemoteConfigClient = previewValue
}
