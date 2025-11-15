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
    @Published var errorMessage: String?
    
    // Dependencies
    private let studentClient: StudentClient
    private let chapelClient: AppClipChapelClient
    
    private var cancellables = Set<AnyCancellable>()
    
    init(studentClient: StudentClient? = nil, chapelClient: AppClipChapelClient? = nil) {
        self.studentClient = studentClient ?? StudentClient.liveValue
        self.chapelClient = chapelClient ?? AppClipChapelClient.liveValue
    }
    
    // onAppear - 저장된 로그인 정보 불러오기
    func loadSavedCredentials() async {
        do {
            let saintInfo = try await studentClient.getSaintInfo()
            self.id = saintInfo.id
            self.password = saintInfo.password
        } catch {
            // 저장된 정보 없음 - 빈 상태 유지
            print("저장된 로그인 정보 없음")
        }
    }
    
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
        let saintInfo = SaintInfo(id: id, password: password)
        
        do {
            // 1. Saint 정보 저장
            try await studentClient.setSaintInfo(saintInfo: saintInfo)
            
            // 2. 학생 정보 설정
            try await studentClient.setStudentInfo()
            
            // 3. 채플 정보 가져오기
            var chapel: ChapelCard
            do {
                chapel = try await chapelClient.fetchChapelCard()
//                try await chapelClient.updateChapelCard(chapelReport)
//                chapel = try await chapelClient.getChapelCard()
            } catch ChapelError.noChapelData {
                // 채플 데이터가 없는 경우
                chapel = ChapelCard.inactive()
            } catch ChapelError.networkError {
                print("채플 정보 네트워크 에러")
                chapel = ChapelCard.inactive()
            } catch {
                // 기타 에러
                print("채플 정보 조회 중 알 수 없는 오류: \(error)")
                chapel = ChapelCard.inactive()
            }
            
            // 4. 학생 정보 확인 (이름 표시 등)
            let studentInfo = try await studentClient.getStudentInfo()
            
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
    }
    
    private func handleLoginFailure(error: Error) async {
        debugPrint("로그인 에러: \(error)")
        
        // 저장된 정보 삭제
        do {
            try await studentClient.deleteStudentInfo()
        } catch {
            print("학생 정보 삭제 실패: \(error)")
        }
        
        isLoading = false
        isLoggedIn = false
        
        // 에러 메시지 설정
        errorMessage = "로그인에 실패하였습니다. 다시 시도해주세요!"
    }
}
