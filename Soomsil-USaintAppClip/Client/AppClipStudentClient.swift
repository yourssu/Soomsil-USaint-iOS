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
            print("=== 앱클립 로그인 시작 ===")
            print("ID: \(id)")
            print("PW: \(password)")
            
            /*
            // ID/비밀번호를 직접 받아서 세션 생성 (저장하지 않음)
            let session = try await USaintSessionBuilder()
                .withPassword(id: id, password: password)
            return session
             */
            do {
                print("USaintSessionBuilder 생성 중")
                let builder = USaintSessionBuilder()
                print("Builder 생성 완료")
                
                print("withPassword 호출중")
                // FIXME: 여기에서 일반 에러 던짐
                let session = try await builder.withPassword(id: id, password: password)
                print("세션 생성 성공")
                print("Session Type: \(type(of: session))")
                
                return session
            } catch let error as RusaintError {
                print("❌ RusaintError 발생:")
                switch error {
                case .webDynproError:
                    print("  - WebDynproError: 유세인트 웹 시스템 오류")
                case .invalidClientError:
                    print("  - InvalidClientError: 클라이언트 유효성 오류")
                case .ssoLoginError:
                    print("  - SSOLoginError: 로그인 인증 실패")
                case .applicationError:
                    print("  - ApplicationError: 애플리케이션 오류")
                }
                throw error
            } catch {
                print("❌ 일반 에러 발생:")
                print("  - Type: \(type(of: error))")
                print("  - Description: \(error)")
                print("  - LocalizedDescription: \(error.localizedDescription)")
                
                // NSError 상세 정보
                let nsError = error as NSError
                print("  - Domain: \(nsError.domain)")
                print("  - Code: \(nsError.code)")
                print("  - UserInfo: \(nsError.userInfo)")
                
                // URLError인 경우 추가 정보
                if let urlError = error as? URLError {
                    print("  - URLError Code: \(urlError.code)")
                    print("  - Failing URL: \(urlError.failingURL?.absoluteString ?? "nil")")
                }
                
                throw error
            }
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
