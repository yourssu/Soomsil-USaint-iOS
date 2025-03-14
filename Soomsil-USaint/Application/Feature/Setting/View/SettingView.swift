//
//  SettingView.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 1/24/25.
//

import SwiftUI

import ComposableArchitecture
import YDS_SwiftUI

struct SettingView: View {
    @Perception.Bindable var store: StoreOf<SettingReducer>
    
    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 4) {
                SettingList(isPushAuthorizationEnabled: $store.permission) { tappedItem in
                    switch tappedItem {
                    case .logout:
                        store.send(.logoutButtonTapped)
                    case .toggleAuthorization(let granted):
                        store.send(.togglePushAuthorization(granted))
                    case .termsOfService:
                        store.send(.termsOfServiceButtonTapped)
                    case .privacyPolicy:
                        store.send(.privacyPolicyButtonTapped)
                    }
                }
            }
            .registerYDSToast()
            .alert(
                $store.scope(state: \.alert, action: \.alert)
            )
        }
        .navigationTitle("설정")
    }
    
    struct SettingList: View {
        @Binding var isPushAuthorizationEnabled: Bool
        
        let listItemTapped: (listItem) -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                ListRowView(
                    title: "계정관리",
                    items: [
                        RowView(text: "로그아웃",
                                  rightItem: .none,
                                  action: {
                                      listItemTapped(.logout)
                                  }
                                 )
                    ]
                )
                
                ListRowView(
                    title: "알림",
                    items: [
                        RowView(text: "성적 알림 받기",
                                  rightItem: .toggle(
                                    isPushAuthorizationEnabled: $isPushAuthorizationEnabled
                                  ),
                                  action: {
                                      listItemTapped(.toggleAuthorization(isPushAuthorizationEnabled))
                                  }
                                 )
                    ])
                
                ListRowView(
                    title: "약관",
                    items: [
                        RowView(
                            text: "이용약관",
                            rightItem: .none,
                            action: {
                                listItemTapped(.termsOfService)
                            }
                        ),
                        RowView(
                            text: "개인정보 처리 방침",
                            rightItem: .none,
                            action: {
                                listItemTapped(.privacyPolicy)
                            }
                        )
                    ]
                )
                
                ListRowView(
                    title: "버전정보",
                    items: [
                        RowView(
                            text: currentAppVersion(),
                            rightItem: .none,
                            action: {}
                        )
                    ])
            }
            Spacer()
        }
    }
}

private extension SettingView.SettingList {
    func currentAppVersion() -> String {
        if let info: [String: Any] = Bundle.main.infoDictionary,
           let currentVersion: String
            = info["CFBundleShortVersionString"] as? String {
            return currentVersion
        }
        return "-"
    }
}

enum listItem {
    case logout
    case toggleAuthorization(Bool)
    case termsOfService
    case privacyPolicy
}

#Preview {
    SettingView(store: Store(initialState: SettingReducer.State()) {
        SettingReducer()
    })
}
