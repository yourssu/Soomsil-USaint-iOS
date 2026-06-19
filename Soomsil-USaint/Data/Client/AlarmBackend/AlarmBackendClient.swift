//
//  AlarmBackendClient.swift
//  Soomsil-USaint
//

import Foundation

import ComposableArchitecture

struct AlarmBackendClient {
    var registerDevice: @Sendable (_ fcmToken: String) async throws -> Void
    var registerStoredDevice: @Sendable () async throws -> Void
}

extension DependencyValues {
    var alarmBackendClient: AlarmBackendClient {
        get { self[AlarmBackendClient.self] }
        set { self[AlarmBackendClient.self] = newValue }
    }
}

extension AlarmBackendClient: DependencyKey {
    static let liveValue: AlarmBackendClient = {
        let baseURL = URL(string: "https://usaint-alarm-backend-production.up.railway.app")!
        let session = URLSession.shared
        let encoder = JSONEncoder()

        return Self(
            registerDevice: { fcmToken in
                try await performRegisterDevice(
                    fcmToken: fcmToken,
                    baseURL: baseURL,
                    session: session,
                    encoder: encoder
                )
            },
            registerStoredDevice: {
                guard let fcmToken = UserDefaults.standard.string(forKey: RemoteNotificationStorageKey.fcmToken) else {
                    return
                }

                try await performRegisterDevice(
                    fcmToken: fcmToken,
                    baseURL: baseURL,
                    session: session,
                    encoder: encoder
                )
            }
        )
    }()

    static let previewValue: AlarmBackendClient = Self(
        registerDevice: { _ in },
        registerStoredDevice: {}
    )

    static let testValue: AlarmBackendClient = previewValue
}

private enum AlarmBackendError: Error {
    case missingStudentID
    case invalidResponse
    case requestFailed(Int)
}

private struct DeviceRegisterRequest: Encodable {
    let ssuId: String
    let fcmToken: String
    let platform: String
    let appVersion: String?
}

private func performRegisterDevice(
    fcmToken: String,
    baseURL: URL,
    session: URLSession,
    encoder: JSONEncoder
) async throws {
    guard let ssuId = StudentClient.keychain["saintID"], !ssuId.isEmpty else {
        throw AlarmBackendError.missingStudentID
    }

    let requestBody = DeviceRegisterRequest(
        ssuId: ssuId,
        fcmToken: fcmToken,
        platform: "IOS",
        appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    )

    try await sendJSON(
        requestBody,
        path: "/api/v1/devices",
        baseURL: baseURL,
        session: session,
        encoder: encoder
    )
}

private func sendJSON<T: Encodable>(
    _ body: T,
    path: String,
    baseURL: URL,
    session: URLSession,
    encoder: JSONEncoder
) async throws {
    var request = URLRequest(url: baseURL.appendingPathComponent(path))
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try encoder.encode(body)

    let (_, response) = try await session.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
        throw AlarmBackendError.invalidResponse
    }

    guard (200..<300).contains(httpResponse.statusCode) else {
        throw AlarmBackendError.requestFailed(httpResponse.statusCode)
    }
}
