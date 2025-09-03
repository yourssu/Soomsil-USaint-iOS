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
    var getMinimumVersion: @Sendable () async throws -> String
}

extension DependencyValues {
    var remoteConfigClient: RemoteConfigClient {
        get { self[RemoteConfigClient.self] }
        set { self[RemoteConfigClient.self] = newValue }
    }
}

// MARK: - 키 이름 및 환경별 분기

private enum RCKey {
    static let minVersion = "min_version_ios"
}

private enum RCDefaults {
    static let fallbackVersion = "0.0.0"
}

extension RemoteConfigClient: DependencyKey {

    static let liveValue: RemoteConfigClient = RemoteConfigClient.live()

    static let previewValue: RemoteConfigClient = Self(
        getMinimumVersion: {
            return "3.0.3"
        }
    )

    static let testValue: RemoteConfigClient = previewValue

    // MARK: - 분리된 live() 함수에서 비동기 처리

    static func live() -> RemoteConfigClient {
        #if targetEnvironment(simulator)
        // 시뮬레이터에서는 업데이트 강제 안함
        return previewValue
        #else
        return Self(
            getMinimumVersion: {
                let rc = RemoteConfig.remoteConfig()

                // Remote Config 기본값 설정 (key 누락 대비)
                rc.setDefaults([RCKey.minVersion: RCDefaults.fallbackVersion as NSObject])

                // DEBUG에서 fetch 간격 짧게
                #if DEBUG
                let settings = RemoteConfigSettings()
                settings.minimumFetchInterval = 0
                rc.configSettings = settings
                #endif

                do {
                    try await rc.fetchAndActivate()
                    let version = rc[RCKey.minVersion].stringValue ?? RCDefaults.fallbackVersion
                    return version
                } catch {
                    print("🔥 RemoteConfig fetch failed: \(error)")
                    return RCDefaults.fallbackVersion
                }
            }
        )
        #endif
    }
}
