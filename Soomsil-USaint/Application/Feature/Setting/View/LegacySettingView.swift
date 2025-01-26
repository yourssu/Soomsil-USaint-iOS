//
//  LegacySettingView.swift
//  Soomsil-USaint-iOS
//
//  Created by 이조은 on 12/18/24.
//

import UIKit
import SwiftUI 
import YDS_SwiftUI

import WebKit

enum ActiveAlert: Identifiable {
    case logout
    case permission

    var id: String {
        switch self {
        case .logout:
            return "logout"
        case .permission:
            return "permission"
        }
    }
}

struct LegacySettingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var path: [StackView]
    @Binding var isLoggedIn: Bool

    @State private var activeAlert: ActiveAlert?
    @State private var isNotificationPermission: Bool = LocalNotificationManager.shared.getNotificationPermission()

    var body: some View {
        VStack(alignment: .leading) {
            Text("설정")
                .font(YDSFont.title2)
                .padding(.top, 8)
                .padding(.leading, 16)
            ButtonList(title: "계정관리", items: [itemAction(
                text: "로그아웃",
                action: { activeAlert = .logout }
            )])
            VStack(alignment: .leading, spacing: 0) {
                Text("알림")
                    .font(YDSFont.subtitle3)
                    .foregroundColor(YDSColor.textSecondary)
                    .padding(20)
                    .frame(height: 48)

                HStack {
                    Text("알림 받기")
                        .font(YDSFont.button3)
                        .foregroundColor(YDSColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Toggle("", isOn: $isNotificationPermission)
                        .labelsHidden()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .tint(YDSColor.buttonPoint)
                        .onChange(of: isNotificationPermission) { newValue in
                            if newValue {
                                LocalNotificationManager.shared.check(completion: { result in
                                    if result {
                                        isNotificationPermission = true
                                    } else {
                                        isNotificationPermission = false
                                        activeAlert = .permission
                                    }
                                })
                            } else {
                                isNotificationPermission = false
                            }
                            LocalNotificationManager.shared.saveNotificationPermission(isNotificationPermission)
                        }
                }
                .padding(20)
                .frame(height: 48)
            }
            ButtonList(title: "약관", items: [itemAction(
                text: "이용약관",
                action: { path.append(StackView(type: .WebViewTerm)) }
            ),itemAction(
                text: "개인정보 처리 방침",
                action: { path.append(StackView(type: .WebViewPrivacy)) }
            )])
            Spacer()
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .logout:
                return Alert(
                    title: Text("로그아웃 하시겠습니까?"),
                    message: nil,
                    primaryButton: .default(Text("취소")),
                    secondaryButton: .destructive(Text("로그아웃"), action: { logOut() })
                )
            case .permission:
                return Alert(
                    title: Text("알림 설정"),
                    message: Text("알림에 대한 권한 사용을 거부하였습니다. 기능 사용을 원하실 경우 설정 > 앱 > 숨쉴때 유세인트 > 알림 권한 허용을 해주세요."),
                    primaryButton: .default(Text("취소")),
                    secondaryButton: .default(Text("설정"), action: { requestNotificationPermission() })
                )
            }
        }
        .onAppear() {
            isNotificationPermission = LocalNotificationManager.shared.getNotificationPermission()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("ic_arrow_left_line")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
        }
    }

    private func logOut() {
        // deleteAllData? deleteInfoData?
        HomeRepository.shared.deleteUserInformation()
        HomeRepository.shared.deleteAllData()
        SemesterRepository.shared.deleteSemesterList()
        path = []
        
        // TODO: // AppReducer의 상태 바꿔주는 형식으로 변환
        isLoggedIn = false
    }

    private func requestNotificationPermission() {
        LocalNotificationManager.shared.requestAuthorization(completion: { result in
            if !result {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                DispatchQueue.main.async {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        })
    }
}

// MARK: - WebView
struct WebView: UIViewRepresentable {
    var urlToLoad: String

    @Binding var path: [StackView]
    @Environment(\.dismiss) var dismiss

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        if let url = URL(string: self.urlToLoad) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Failed to load WebView: \(error.localizedDescription)")
        }

        func handleBackAction() {
            parent.dismiss()
        }
    }
}

struct WebViewContainer: View {
    @Binding var path: [StackView]
    var urlToLoad: String

    var body: some View {
        WebView(urlToLoad: urlToLoad, path: $path)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        path.removeLast()
                    } label: {
                        Image("ic_arrow_left_line")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
    }
}

#Preview {
//    @Previewable @State var isLoggedIn: Bool = true
//
//    SettingView(path: .constant([]), isLoggedIn: $isLoggedIn)
}
