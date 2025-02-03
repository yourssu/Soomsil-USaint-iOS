//
//  RootView.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 2/3/25.
//

import SwiftUI

import ComposableArchitecture

struct RootView: View {
    @Perception.Bindable var store: StoreOf<RootReducer>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack(
                path: $store.scope(state: \.path, action: \.path)
            ) {
                HomeView(store: store.scope(state: \.home, action: \.home))
            } destination: { store in
                switch store.case {
                case .setting(let store):
                    SettingView(store: store)
                case .web(let store):
                    WebView(store: store)
                }
            }
        }
    }
}

#Preview {
    RootView(
        store: Store(
            initialState: RootReducer.State(
                home: HomeReducer.State(
                    studentInfo: StudentInfo(name: "000", major: "글로벌미디어학부", schoolYear: "6학년"),
                    totalReportCard: TotalReportCard(gpa: 3.4, earnedCredit: 34.5, graduateCredit: 124.0)
                )
            ),
            reducer: { RootReducer() }
        )
    )
}
