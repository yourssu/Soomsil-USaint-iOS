//
//  MainTabView.swift
//  Soomsil-USaint
//

import SwiftUI

import ComposableArchitecture

struct MainTabView: View {
    @Bindable var store: StoreOf<MainTabReducer>

    var body: some View {
        tabContent
            .safeAreaInset(edge: .bottom) {
                if showsTabBar {
                    CustomTabBar(selectedTab: Binding(
                        get: { store.selectedTab },
                        set: { store.send(.tabSelected($0)) }
                    ))
                }
            }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch store.selectedTab {
        case .home:
            HomeView(store: store.scope(state: \.homeState, action: \.home))
        case .chapel:
            ChapelView(store: store.scope(state: \.chapelState, action: \.chapel))
        case .notification:
            placeholderView(TextLiteral.MainTabView.notificationPlaceholder)
        case .my:
            SettingView(
                store: store.scope(state: \.settingState, action: \.setting)
            )
        }
    }

    private func placeholderView(_ text: String) -> some View {
        Text(text)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundSurface)
    }

    private var showsTabBar: Bool {
        switch store.selectedTab {
        case .home:
            store.homeState.path.isEmpty
        case .chapel:
            store.chapelState.path.isEmpty
        case .notification, .my:
            true
        }
    }
}

#Preview {
    MainTabView(store: Store(
        initialState: MainTabReducer.State(
            studentInfo: StudentInfo(
                name: "000",
                major: "글로벌미디어학부",
                schoolYear: "4학년"
            ),
            totalReportCard: TotalReportCard(gpa: 4.22, earnedCredit: 34.5, graduateCredit: 124.0, generalRank: 10, overallStudentCount: 100),
            chapelCard: ChapelCard(
                attendance: 4,
                seatPosition: "E-10-4",
                floorLevel: 1
            )
        )
    ) {
        MainTabReducer()
    })
}
