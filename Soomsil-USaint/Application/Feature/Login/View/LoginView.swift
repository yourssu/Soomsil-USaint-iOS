//
//  LoginView.swift
//  Soomsil-USaint-iOS
//
//  Created by 이조은 on 12/16/24.
//

import SwiftUI

import ComposableArchitecture
import Rusaint
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
    @Perception.Bindable var store: StoreOf<LoginReducer>
    
    var body: some View {
        // MARK: iOS 16 이하 대응 - WithPerceptionTracking로 감싸지 않을 경우, Perceptible state was accessed but is not being tracked. 메모리 관련 경고 발생
        WithPerceptionTracking {
            VStack(spacing: 4) {
                title
                form
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
    }
}

private extension LoginView {
    var title: some View {
        Text("로그인")
            .font(YDSFont.subtitle2)
    }
    
    var form: some View {
        VStack(alignment: .leading, spacing: Dimension.VStack.spacing) {
            Text("학번")
                .font(YDSFont.body1)
            YDSSimpleTextField(text: $store.id)
            
            Text("유세인트 비밀번호")
                .font(YDSFont.body1)
            SecureTextField(text: $store.password)
                .padding(.bottom, Dimension.largeSpace)
            
            Button {
                store.send(.loginPressed)
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

#Preview {
    LoginView(store: Store(initialState: LoginReducer.State()) {
        LoginReducer()
    })
}
