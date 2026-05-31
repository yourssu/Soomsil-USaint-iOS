//
//  LoginView.swift
//  Soomsil-USaint-iOS
//
//  Created by 이조은 on 12/16/24.
//

import SwiftUI
import UIKit

import ComposableArchitecture
import YDS_SwiftUI

struct LoginView: View {
    @Bindable var store: StoreOf<LoginReducer>
    @State private var isPasswordSecured = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LoginLogoView()
                .padding(.top, 96)
                .padding(.bottom, 64)

            VStack(alignment: .leading, spacing: 12) {
                Text("유세인트에\n로그인해주세요")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.adaptivePrimaryText)
                    .lineSpacing(4)

                Text("학사 정보를 한눈에 확인할 수 있어요")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.adaptiveSecondaryText)
            }
            .padding(.bottom, 76)

            VStack(spacing: 12) {
                LoginInputRow(
                    placeholder: "학번",
                    text: $store.id,
                    isSecure: false,
                    isPasswordSecured: .constant(false)
                )

                LoginInputRow(
                    placeholder: "비밀번호",
                    text: $store.password,
                    isSecure: true,
                    isPasswordSecured: $isPasswordSecured
                )
            }
            .padding(.bottom, 70)

            Button {
                store.send(.loginPressed)
            } label: {
                Text("로그인")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(.blue600)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.adaptiveBackground)
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

private struct LoginLogoView: View {
    var body: some View {
        Group {
            if let icon = AppIconLoader.image {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.gray200)
            }
        }
        .frame(width: 96, height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct LoginInputRow: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    @Binding var isPasswordSecured: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(placeholder)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.adaptiveSecondaryText)

            if isSecure && isPasswordSecured {
                SecureField("", text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(Color.adaptivePrimaryText)
            } else {
                TextField("", text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(isSecure ? .default : .numberPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(Color.adaptivePrimaryText)
            }

            if isSecure {
                Button {
                    isPasswordSecured.toggle()
                } label: {
                    Image(systemName: isPasswordSecured ? "eye" : "eye.slash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.adaptiveSecondaryText)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .font(.system(size: 16, weight: .bold))
        .padding(.horizontal, 24)
        .frame(height: 68)
        .background(Color.adaptiveInputSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.adaptiveBorder, lineWidth: 1)
        )
    }
}

private enum AppIconLoader {
    static var image: UIImage? {
        guard
            let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let iconName = iconFiles.last
        else {
            return nil
        }
        return UIImage(named: iconName)
    }
}

#Preview {
    LoginView(store: Store(initialState: LoginReducer.State()) {
        LoginReducer()
    })
}
