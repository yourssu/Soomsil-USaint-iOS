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
    @Bindable var store: StoreOf<SettingReducer>
    
    var body: some View {
        VStack(spacing: 0) {
            Text(TextLiteral.SettingView.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.gray950)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6.5)
            
            SettingList(
                isPushAuthorizationEnabled: $store.permission,
                appVersion: store.appVersion
            ) { tappedItem in
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
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    struct SettingList: View {
        @Binding var isPushAuthorizationEnabled: Bool
        
        let appVersion: String
        let listItemTapped: (listItem) -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                ListRowView(
                    title: TextLiteral.SettingView.accountSectionTitle,
                    items: [
                        RowView(text: TextLiteral.SettingView.logoutButtonTitle,
                                rightItem: .none,
                                action: {
                                    listItemTapped(.logout)
                                }
                               )
                    ]
                )
                
                Divider()
                
                ListRowView(
                    title: TextLiteral.SettingView.notificationSectionTitle,
                    items: [
                        RowView(text: TextLiteral.SettingView.gradeNotificationTitle,
                                rightItem: .toggle(
                                    isPushAuthorizationEnabled: $isPushAuthorizationEnabled
                                ),
                                action: {
                                    listItemTapped(.toggleAuthorization(isPushAuthorizationEnabled))
                                }
                               )
                    ])
                
                ListRowView(
                    title: TextLiteral.SettingView.termsSectionTitle,
                    items: [
                        RowView(
                            text: TextLiteral.SettingView.termsOfServiceTitle,
                            rightItem: .none,
                            action: {
                                listItemTapped(.termsOfService)
                            }
                        ),
                        RowView(
                            text: TextLiteral.SettingView.privacyPolicyTitle,
                            rightItem: .none,
                            action: {
                                listItemTapped(.privacyPolicy)
                            }
                        )
                    ]
                )
                
                Divider()
                
                ListRowView(
                    title: TextLiteral.SettingView.versionSectionTitle,
                    items: [
                        RowView(
                            text: TextLiteral.SettingView.appVersion(appVersion),
                            rightItem: .none,
                            isEnabled: false,
                            action: {}
                        )
                    ])
            }
            Spacer()
        }
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
