//
//  StudentClient.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

/**
 Rusaint에서 반환하는 오류

 현재 오류에 대한 세부정보를 연관 값으로 받지 않고 에러 타입만 정의해둔 상태
 */

public enum RusaintError: Error {
    case webDynproError
    case invalidClientError
    case ssoLoginError
    case applicationError
}

public enum StudentError: Error {
    case accessKeychainError
    case accessSecretConfigError
}

import Foundation
import KeychainAccess

import ComposableArchitecture
import Rusaint

@DependencyClient
struct StudentClient {
    static let keychain = Keychain(service: "com.yourssu.soomsil-ios")

    var getSaintInfo: @Sendable () async throws -> SaintInfo
    var setSaintInfo: @Sendable (_ saintInfo: SaintInfo) async throws -> Void

    var createSaintSession: @Sendable () async throws -> USaintSession

    var getStudentInfo: @Sendable () async throws -> StudentInfo
    var setStudentInfo: @Sendable () async throws -> Void
    var deleteStudentInfo: @Sendable () async throws -> Void
}

extension DependencyValues {
    var studentClient: StudentClient {
        get { self[StudentClient.self] }
        set { self[StudentClient.self] = newValue }
    }
}

extension StudentClient: DependencyKey {
    static var liveValue: StudentClient = Self(
        getSaintInfo: {
            guard let id = keychain["saintID"], let password = keychain["saintPW"]
            else { throw StudentError.accessKeychainError }
            return SaintInfo(id: id, password: password)
        },
        setSaintInfo: { info  in
            keychain["saintID"] = info.id
            keychain["saintPW"] = info.password
        },
        createSaintSession: {
            guard let id = keychain["saintID"], let password = keychain["saintPW"]
            else { throw StudentError.accessKeychainError }
            let session = try await USaintSessionBuilder().withPassword(id: id, password: password)
            return session
        },
        getStudentInfo: {
            guard let name = keychain["name"], let major = keychain["major"], let schoolYear = keychain["schoolYear"]
            else { throw StudentError.accessKeychainError }
            return StudentInfo(name: name, major: major, schoolYear: schoolYear)
        },
        setStudentInfo: {
            guard let id = keychain["saintID"], let password = keychain["saintPW"]
            else { throw StudentError.accessKeychainError }

            let session = try await USaintSessionBuilder().withPassword(id: id, password: password)
            let studentInfo = try await StudentInformationApplicationBuilder().build(session: session).general()
            let name = studentInfo.name.replacingOccurrences(of: " ", with: "")
            let major = studentInfo.department
            let schoolYear = "\(studentInfo.grade)학년"

            keychain["name"] = name
            keychain["major"] = major
            keychain["schoolYear"] = schoolYear
        }, deleteStudentInfo: {
            try? keychain.remove("saintID")
            try? keychain.remove("saintPW")
            try? keychain.remove("name")
            try? keychain.remove("major")
            try? keychain.remove("schoolYear")
        }
    )

    static let previewValue: StudentClient = Self(
        getSaintInfo: {
            guard let id = keychain["saintID"], let password = keychain["saintPW"]
            else { throw StudentError.accessKeychainError}
            return SaintInfo(id: id, password: password)
        },
        setSaintInfo: { info  in
            guard let id = Bundle.main.object(forInfoDictionaryKey: "SAINT_ID") as? String else { throw StudentError.accessSecretConfigError }
            guard let password = Bundle.main.object(forInfoDictionaryKey: "SAINT_PW") as? String else { throw StudentError.accessSecretConfigError }

            keychain["saintID"] = id
            keychain["saintPW"] = password
        },
        createSaintSession: {
            guard let id = Bundle.main.object(forInfoDictionaryKey: "SAINT_ID") as? String else { throw StudentError.accessSecretConfigError }
            guard let password = Bundle.main.object(forInfoDictionaryKey: "SAINT_PW") as? String else { throw StudentError.accessSecretConfigError }
            let session = try await USaintSessionBuilder().withPassword(id: id, password: password)
            return session
        },
        getStudentInfo: {
            guard let name = keychain["name"], let major = keychain["major"], let schoolYear = keychain["schoolYear"]
            else { throw StudentError.accessKeychainError }
            return StudentInfo(name: name, major: major, schoolYear: schoolYear)
        },
        setStudentInfo: {
            guard let id = Bundle.main.object(forInfoDictionaryKey: "SAINT_ID") as? String else { throw StudentError.accessSecretConfigError }
            guard let password = Bundle.main.object(forInfoDictionaryKey: "SAINT_PW") as? String else { throw StudentError.accessSecretConfigError }

            let session = try await USaintSessionBuilder().withPassword(id: id, password: password)
            let studentInfo = try await StudentInformationApplicationBuilder().build(session: session).general()
            let name = studentInfo.name.replacingOccurrences(of: " ", with: "")
            let major = studentInfo.department
            let schoolYear = "\(studentInfo.grade)학년"

            keychain["name"] = name
            keychain["major"] = major
            keychain["schoolYear"] = schoolYear
        },
        deleteStudentInfo: {
            try? keychain.remove("saintID")
            try? keychain.remove("saintPW")
            try? keychain.remove("name")
            try? keychain.remove("major")
            try? keychain.remove("schoolYear")
        }
    )

    static let testValue: StudentClient = previewValue
}
