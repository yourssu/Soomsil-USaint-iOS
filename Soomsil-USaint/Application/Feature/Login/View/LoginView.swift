//
//  LoginView.swift
//  Soomsil-USaint-iOS
//
//  Created by 이조은 on 12/16/24.
//

import SwiftUI

import ComposableArchitecture
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
    @Bindable var store: StoreOf<LoginReducer>
    
    var body: some View {
        VStack(spacing: 4) {
            title
            LoginForm(id: $store.id, password: $store.password) {
                store.send(.loginPressed)
            }
            Spacer()
        }
        .background {
            Color.clear.tapToHideKeyboard()
        }
        .overlay {
            if store.isLoading {
                CircleLoadingView()
            }
        }
        .registerYDSToast()
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    struct LoginForm: View {
        @Binding var id: String
        @Binding var password: String
        
        let onLoginPressed: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: Dimension.VStack.spacing) {
                Text("학번")
                    .font(YDSFont.body1)
                YDSSimpleTextField(text: $id)
                
                Text("유세인트 비밀번호")
                    .font(YDSFont.body1)
                SecureTextField(text: $password)
                    .padding(.bottom, Dimension.largeSpace)
                
                Button {
                    onLoginPressed()
                } label: {
                    Text("로그인")
                        .foregroundStyle(YDSColor.buttonBright)
                        .font(YDSFont.button4)
                        .frame(maxWidth: .infinity, minHeight: Dimension.Button.minHeight)
                        .background(YDSColor.buttonPoint, in: RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                
                HStack {
                    YDSIcon.warningcircleLine
                        .renderingMode(.template)
                    Text("숨쉴때 유세인트 서비스 이용을 위한 유세인트 학번 및 비밀번호는 사용자 기기에만 저장되며, 유어슈는 유세인트 서비스를 통하여 이용자의 정보를 일체 수집ㆍ저장하지 않습니다.")
                        .font(.caption2)
                }
                .foregroundStyle(YDSColor.textPointed)
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

#Preview {
    LoginView(store: Store(initialState: LoginReducer.State()) {
        LoginReducer()
    })
}
