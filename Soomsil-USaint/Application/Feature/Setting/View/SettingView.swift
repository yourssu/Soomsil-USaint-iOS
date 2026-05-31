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
    @State private var showsNotificationSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            Text(TextLiteral.SettingView.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.gray950)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6.5)

            SettingList(
                appVersion: store.appVersion
            ) { tappedItem in
                switch tappedItem {
                case .logout:
                    store.send(.logoutButtonTapped)
                case .notificationSettings:
                    showsNotificationSettings = true
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
        .fullScreenCover(isPresented: $showsNotificationSettings) {
            NotificationSettingsContainerView {
                showsNotificationSettings = false
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    struct SettingList: View {
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
                        RowView(text: TextLiteral.SettingView.notificationSettingsTitle,
                                rightItem: .none,
                                action: {
                                    listItemTapped(.notificationSettings)
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

struct LogoutDialogView: View {
    let cancel: () -> Void
    let confirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture(perform: cancel)

            VStack(spacing: 26) {
                VStack(spacing: 9) {
                    Text(TextLiteral.SettingReducer.logoutAlertTitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.gray950)

                    Text(TextLiteral.SettingReducer.logoutAlertMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.slate500)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                HStack(spacing: 12) {
                    Button(action: cancel) {
                        Text(TextLiteral.SettingReducer.alertCancelTitle)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.gray950)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.gray25)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                    Button(action: confirm) {
                        Text(TextLiteral.SettingReducer.logoutAlertConfirmTitle)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.blue600)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 40)
            .padding(.horizontal, 34)
            .padding(.bottom, 28)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 34)
        }
    }
}

enum listItem {
    case logout
    case notificationSettings
    case termsOfService
    case privacyPolicy
}

#Preview {
    SettingView(store: Store(initialState: SettingReducer.State()) {
        SettingReducer()
    })
}
