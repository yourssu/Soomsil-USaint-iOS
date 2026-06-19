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
                .foregroundStyle(Color.adaptivePrimaryText)
                .frame(maxWidth: .infinity)
                .padding(.top, 52)
                .padding(.bottom, 8)

            SettingList(
                appVersion: store.appVersion,
                listItemTapped: { tappedItem in
                    switch tappedItem {
                    case .logout:
                        store.send(.logoutButtonTapped)
                    case .termsOfService:
                        store.send(.termsOfServiceButtonTapped)
                    case .privacyPolicy:
                        store.send(.privacyPolicyButtonTapped)
                    }
                },
                notificationToggleChanged: { category, isEnabled in
                    store.send(.notificationCategoryToggled(category, isEnabled))
                }
            )
        }
        .registerYDSToast()
        .alert(
            $store.scope(state: \.alert, action: \.alert)
        )
        .onAppear {
            store.send(.onAppear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.adaptiveBackground)
    }
    
    struct SettingList: View {
        let appVersion: String
        let listItemTapped: (listItem) -> Void
        let notificationToggleChanged: (USaintNotificationCategory, Bool) -> Void
        @AppStorage("gradeAnnouncementNotificationEnabled") private var isGradeNotificationEnabled = true
        @AppStorage("chapelNotificationEnabled") private var isCampusNotificationEnabled = true
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ListRowView(
                    title: TextLiteral.SettingView.accountSectionTitle,
                    items: [
                        RowView(text: TextLiteral.SettingView.logoutButtonTitle,
                                rightItem: .chevron,
                                action: {
                                    listItemTapped(.logout)
                                }
                               )
                    ]
                )

                ListRowView(
                    title: TextLiteral.SettingView.notificationSectionTitle,
                    items: [
                        RowView(
                            text: TextLiteral.SettingView.gradeNotificationTitle,
                            rightItem: .toggle(isPushAuthorizationEnabled: $isGradeNotificationEnabled),
                            action: {
                                notificationToggleChanged(.gradeAnnouncement, isGradeNotificationEnabled)
                            }
                        ),
                        RowView(
                            text: TextLiteral.SettingView.campusNotificationTitle,
                            rightItem: .toggle(isPushAuthorizationEnabled: $isCampusNotificationEnabled),
                            action: {
                                notificationToggleChanged(.chapel, isCampusNotificationEnabled)
                            }
                        )
                    ])
                
                ListRowView(
                    title: TextLiteral.SettingView.termsSectionTitle,
                    items: [
                        RowView(
                            text: TextLiteral.SettingView.termsOfServiceTitle,
                            rightItem: .chevron,
                            action: {
                                listItemTapped(.termsOfService)
                            }
                        ),
                        RowView(
                            text: TextLiteral.SettingView.privacyPolicyTitle,
                            rightItem: .chevron,
                            action: {
                                listItemTapped(.privacyPolicy)
                            }
                        )
                    ]
                )

                ListRowView(
                    title: TextLiteral.SettingView.versionSectionTitle,
                    items: [
                        RowView(
                            text: "버전정보",
                            rightItem: .text(TextLiteral.SettingView.appVersion(appVersion)),
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
                        .foregroundStyle(Color.adaptivePrimaryText)

                    Text(TextLiteral.SettingReducer.logoutAlertMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.adaptiveSecondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                HStack(spacing: 12) {
                    Button(action: cancel) {
                        Text(TextLiteral.SettingReducer.alertCancelTitle)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.adaptivePrimaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.adaptiveMutedSurface)
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
            .background(Color.adaptiveSurface)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 34)
        }
    }
}

enum listItem {
    case logout
    case termsOfService
    case privacyPolicy
}

#Preview {
    SettingView(store: Store(initialState: SettingReducer.State()) {
        SettingReducer()
    })
}
