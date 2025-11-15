//
//  AppClipStudentClient.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 11/16/25.
//

import Foundation
import Dependencies
import Rusaint

// MARK: - 앱클립 전용 Student Client (저장 기능 없음)
struct AppClipStudentClient {
    // ID/비밀번호를 직접 받아서 세션 생성 (Keychain 사용 안 함)
    var createSaintSession: (String, String) async throws -> USaintSession
    
    // 세션으로 학생 정보 가져오기
    var fetchStudentInfo: (USaintSession) async throws -> StudentInfo
}

extension AppClipStudentClient: DependencyKey {
    static let liveValue: AppClipStudentClient = AppClipStudentClient(
        createSaintSession: { id, password in
            // ID/비밀번호를 직접 받아서 세션 생성 (저장하지 않음)
            let session = try await USaintSessionBuilder()
                .withPassword(id: id, password: password)
            return session
        },
        fetchStudentInfo: { session in
            // 세션으로 학생 정보 가져오기
            let studentApp = try await StudentInformationApplicationBuilder()
                .build(session: session)
            let studentRecord = try await studentApp.general()
            
            let name = studentRecord.name.replacingOccurrences(of: " ", with: "")
            let major = studentRecord.department
            let schoolYear = "\(studentRecord.grade)학년"
            
            return StudentInfo(name: name, major: major, schoolYear: schoolYear)
        }
    )
    
    static let previewValue: AppClipStudentClient = AppClipStudentClient(
        createSaintSession: { _, _ in
            // 프리뷰용 더미 세션
            fatalError("Preview session not implemented")
        },
        fetchStudentInfo: { _ in
            return StudentInfo(name: "홍길동", major: "컴퓨터학부", schoolYear: "3학년")
        }
    )
    
    static let testValue: AppClipStudentClient = previewValue
}

extension DependencyValues {
    var appClipStudentClient: AppClipStudentClient {
        get { self[AppClipStudentClient.self] }
        set { self[AppClipStudentClient.self] = newValue }
    }
}

enum RusaintError: Error {
    case webDynproError
    case invalidClientError
    case ssoLoginError
    case applicationError
}
