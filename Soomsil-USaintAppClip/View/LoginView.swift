//
//  LoginView.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 11/15/25.
//

import SwiftUI
import YDS_SwiftUI

private enum Dimension {
    enum VStack {
        static let spacing: CGFloat = 8
    }
    enum Button {
        static let minHeight: CGFloat = 48
    }
    static let largeSpace: CGFloat = 44
    static let padding: CGFloat = 16
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 4) {
            title
            LoginForm(id: $viewModel.id,
                      password: $viewModel.password,
                      onLoginPressed: viewModel.login)
            Spacer()
        }
        .background {
            Color.clear.tapToHideKeyboard()
        }
        .overlay {
            if viewModel.isLoading {
                CircleLoadingView()
            }
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    struct LoginForm: View {
        @Binding var id: String
        @Binding var password: String
        let onLoginPressed: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing:
                    Dimension.VStack.spacing) {
                Text("학번")
                    .font(YDSFont.body1)
                    .foregroundStyle(.titleText)
                
                YDSSimpleTextField(text: $id)
                
                Text("유세인트 비밀번호")
                    .font(YDSFont.body1)
                    .foregroundStyle(.titleText)
                
                SecureTextField(text: $password)
                    .padding(.bottom, Dimension.largeSpace)
                
                Button {
                    onLoginPressed()
                } label: {
                    Text("로그인")
                        .foregroundStyle(.smallText)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity, minHeight: Dimension.Button.minHeight)
                        .background(.vPrimary, in: RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                
                HStack {
                    YDSIcon.warningcircleLine
                        .renderingMode(.template)
                    Text("숨쉴때 유세인트 서비스 이용을 위한 유세인트 학번 및 비밀번호는 사용자 기기에만 저장되며, 유어슈는 유세인트 서비스를 통하여 이용자의 정보를 일체 수집ㆍ저장하지 않습니다.")
                        .font(.caption2)
                }
                .foregroundStyle(.vPrimary)
            }
            .padding(Dimension.padding)
        }
        
    }
}

private extension LoginView {
    var title: some View {
        Text("로그인")
            .font(YDSFont.subtitle2)
    }
}
