//
//  LoginViewModel.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 11/16/25.
//

import SwiftUI
import Combine
import Dependencies

@MainActor
class LoginViewModel: ObservableObject {
    // Input
    @Published var id: String = ""
    @Published var password: String = ""
    
    // Output
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var studentInfo: StudentInfo?
    @Published var chapel: ChapelCard?
    @Published var errorMessage: String?
    
    // Dependencies
//    private let studentClient: StudentClient
//    private let chapelClient: AppClipChapelClient
    @Dependency(\.appClipStudentClient) private var studentClient
    @Dependency(\.appClipChapelClient) private var chapelClient
    
    private var cancellables = Set<AnyCancellable>()
    
//    init(studentClient: StudentClient? = nil, chapelClient: AppClipChapelClient? = nil) {
//        self.studentClient = studentClient ?? StudentClient.liveValue
//        self.chapelClient = chapelClient ?? AppClipChapelClient.liveValue
//    }
    init() {}
    
    // onAppear - 저장된 로그인 정보 불러오기
//    func loadSavedCredentials() async {
//        do {
//            let saintInfo = try await studentClient.getSaintInfo()
//            self.id = saintInfo.id
//            self.password = saintInfo.password
//        } catch {
//            // 저장된 정보 없음 - 빈 상태 유지
//            print("저장된 로그인 정보 없음")
//        }
//    }
    
    func login() {
        // 입력 검증
        guard !id.isEmpty, !password.isEmpty else {
            errorMessage = "학번과 비밀번호를 입력해주세요"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            await performLogin()
        }
    }
    
    private func performLogin() async {
//        let saintInfo = SaintInfo(id: id, password: password)
        
        do {
            // 1. 세션 생성 (Keychain에 저장하지 않고 바로 생성)
            let session = try await studentClient.createSaintSession(id, password)
            
            // 2. 학생 정보 가져오기
            let studentInfo = try await studentClient.fetchStudentInfo(session)
            
            // 3. 채플 정보 가져오기
            let chapel: ChapelCard
            do {
                chapel = try await chapelClient.fetchChapelCard(session)
            } catch ChapelError.noChapelData {
                // 채플 데이터가 없는 경우 (졸업생 등)
                chapel = ChapelCard.inactive()
            } catch ChapelError.networkError {
                print("채플 정보 네트워크 에러")
                chapel = ChapelCard.inactive()
            } catch {
                print("채플 정보 조회 중 알 수 없는 오류: \(error)")
                throw error
            }
            
            // 성공 처리
            await handleLoginSuccess(studentInfo: studentInfo, chapel: chapel)
            
        } catch {
            // 실패 처리
            await handleLoginFailure(error: error)
        }
    }
    
    private func handleLoginSuccess(studentInfo: StudentInfo, chapel: ChapelCard) async {
        isLoading = false
        isLoggedIn = true
        self.studentInfo = studentInfo
        self.chapel = chapel
    }
    
    private func handleLoginFailure(error: Error) async {
        debugPrint("로그인 에러: \(error)")
        
        isLoading = false
        isLoggedIn = false
        
        // 에러 타입별 메시지
        if let rusaintError = error as? RusaintError {
            switch rusaintError {
            case .ssoLoginError:
                errorMessage = "아이디 또는 비밀번호가 올바르지 않습니다."
            case .webDynproError, .applicationError:
                errorMessage = "유세인트 서버 오류입니다. 잠시 후 다시 시도해주세요."
            case .invalidClientError:
                errorMessage = "로그인 세션이 유효하지 않습니다."
            }
        } else if error is URLError {
            errorMessage = "네트워크 연결을 확인해주세요."
        } else {
            errorMessage = "로그인에 실패하였습니다. 다시 시도해주세요!"
        }
    }
}
