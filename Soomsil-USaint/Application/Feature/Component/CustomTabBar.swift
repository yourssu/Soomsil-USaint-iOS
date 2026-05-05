//
//  CustomTabBar.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/5/26.
//

import SwiftUI

enum MainTabItem: CaseIterable, Hashable {
    case home
    case chapel
    case notification
    case my

    var title: String {
        switch self {
        case .home: return "홈"
        case .chapel: return "채플"
        case .notification: return "알림"
        case .my: return "마이"
        }
    }

    var icon: Image {
        switch self {
        case .home: return Icon.home
        case .chapel: return Icon.sofa
        case .notification: return Icon.bell
        case .my: return Icon.person
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabItem

    var body: some View {
        HStack(spacing: 4) {
            ForEach(MainTabItem.allCases, id: \.self) { tab in
                tabItem(for: tab)
            }
        }
        .padding(6)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(.slate100, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private func tabItem(for tab: MainTabItem) -> some View {
        let isSelected = selectedTab == tab
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                tab.icon
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(isSelected ? .white : .gray500)
                Text(tab.title)
                    .font(
                        .system(
                            size: isSelected ? 12 : 10,
                            weight: isSelected ? .semibold : .medium
                        )
                    )
                    .foregroundStyle(isSelected ? .white : .gray500)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? .blue600 : .clear)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab: MainTabItem = .home
        var body: some View {
            ZStack(alignment: .bottom) {
                Color.gray.ignoresSafeArea()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
    return PreviewWrapper()
}
