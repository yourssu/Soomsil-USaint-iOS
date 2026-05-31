//
//  SemesterTabView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import SwiftUI

struct SemesterTabView: View {
    // MARK: - Properties

    private let tabs: [SemesterTab]
    @Binding private var activeTab: SemesterTab.ID

    /// 학기 탭 구성
    /// - Parameters:
    ///   - tabs: 학기 탭 목록
    ///   - activeTab: 선택된 학기 탭
    init(
        tabs: [SemesterTab],
        activeTab: Binding<SemesterTab.ID>
    ) {
        self.tabs = tabs
        self._activeTab = activeTab
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tabs) { tab in
                    tabButton(tab)
                }
            }
        }
        .padding(.trailing, -20)
    }
}

// MARK: - View

private extension SemesterTabView {
    /// 학기 탭 버튼 구성
    /// - Parameter tab: 학기 탭
    func tabButton(_ tab: SemesterTab) -> some View {
        let isSelected = activeTab == tab.id

        return Button {
            withAnimation(.snappy) {
                activeTab = tab.id
            }
        } label: {
            Text(tab.id)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color.adaptiveSecondaryText)
                .padding(.horizontal, 17)
                .padding(.vertical, 8)
                .background(isSelected ? Color.adaptiveSelectedPill : Color.adaptiveMutedSurface)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var activeTab = "2025년 1학기"

    SemesterTabView(
        tabs: [
            SemesterTab(id: "2025년 1학기"),
            SemesterTab(id: "2024년 2학기"),
            SemesterTab(id: "2024년 여름학기"),
            SemesterTab(id: "2024년 1학기"),
            SemesterTab(id: "2023년 겨울학기")
        ],
        activeTab: $activeTab
    )
    .padding(.leading, 20)
}
