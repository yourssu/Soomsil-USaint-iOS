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
                title
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
    }
    
    struct SettingList: View {
        @Binding var isPushAuthorizationEnabled: Bool
        
        let listItemTapped: (listItem) -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                ListRowView(
                    title: "계정관리",
                    items: [
                        ItemModel(text: "로그아웃",
                                  rightItem: .none,
                                  action: {
                                      listItemTapped(.logout)
                                  }
                                 )
                    ]
                )
                
                ListRowView(title: "알림",
                            items: [
                                ItemModel(text: "성적 알림 받기",
                                          rightItem: .toggle(
                                            isPushAuthorizationEnabled: $isPushAuthorizationEnabled
                                          ),
                                          action: {
                                              // TODO: onChange 호출시 액션 전달
                                          }
                                         )
                            ])
                
                ListRowView(
                    title: "약관",
                    items: [
                        ItemModel(text: "이용약관",
                                  rightItem: .none,
                                  action: {
                                      listItemTapped(.termsOfService)
                                  }
                                 ),
                        ItemModel(text: "개인정보 처리 방침",
                                  rightItem: .none,
                                  action: {
                                      listItemTapped(.privacyPolicy)
                                  }
                                 )
                    ]
                )
                Spacer()
            }
        }
    }
}

private extension SettingView {
    var title: some View {
        Text("설정")
            .font(YDSFont.subtitle2)
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
