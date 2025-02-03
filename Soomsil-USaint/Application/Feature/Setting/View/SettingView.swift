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
            if let store = store.scope(state: \.appState, action: \.appState) {
                AppView(store: store)
            } else {
                NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
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

                } destination: { store in
                    switch store.case {
                    case .navigateToTermsWebView(let store):
                        WebView(store: store)
                    }
                }
                .alert(
                    $store.scope(state: \.alert, action: \.alert)
                )
            }
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
                        itemAction(
                            text: "로그아웃",
                            action: {
                                listItemTapped(.logout)
                            }
                        )
                    ]
                )
                VStack(alignment: .leading, spacing: 0) {
                    Text("알림")
                        .font(YDSFont.subtitle3)
                        .foregroundColor(YDSColor.textSecondary)
                        .padding(20)
                        .frame(height: 48)
                    HStack {
                        Text("성적 알림 받기")
                            .font(YDSFont.button3)
                            .foregroundColor(YDSColor.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Toggle("", isOn: $isPushAuthorizationEnabled)
                            .labelsHidden()
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            .tint(YDSColor.buttonPoint)
                            .onChange(of: isPushAuthorizationEnabled) { newValue in
                                listItemTapped(.toggleAuthorization(newValue))
                            }
                    }
                    .padding(20)
                    .frame(height: 48)
                }
                ListRowView(
                    title: "약관",
                    items: [
                        itemAction(
                            text: "이용약관",
                            action: {
                                listItemTapped(.termsOfService)
                            }
                        ),
                        itemAction(
                            text: "개인정보 처리 방침",
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

// MARK: - List
enum listItem {
    case logout
    case toggleAuthorization(Bool)
    case termsOfService
    case privacyPolicy
}

struct itemAction {
    let text: String
    let action: () -> Void
}

struct ListRowView: View {
    let title: String
    let items: [itemAction]
    
    @State private var pressedStates: [Bool]
    
    init(title: String, items: [itemAction]) {
        self.title = title
        self.items = items
        self._pressedStates = State(initialValue: Array(repeating: false, count: items.count))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(YDSFont.subtitle3)
                .foregroundColor(YDSColor.textSecondary)
                .padding(20)
                .frame(height: 48)
            
            ForEach(items.indices, id: \.self) { index in
                ItemModel(
                    text: items[index].text,
                    action: items[index].action,
                    isPressed: $pressedStates[index]
                )
            }
        }
    }
}

struct ItemModel: View {
    let text: String
    let action: () -> Void
    @Binding var isPressed: Bool
    
    var body: some View {
        Text(text)
            .font(YDSFont.button3)
            .foregroundColor(YDSColor.textSecondary)
            .padding(20)
            .frame(height: 48)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isPressed ? Color(red: 0.95, green: 0.96, blue: 0.97) : Color.clear)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}

#Preview {
    SettingView(store: Store(initialState: SettingReducer.State()) {
        SettingReducer()
    })
}
