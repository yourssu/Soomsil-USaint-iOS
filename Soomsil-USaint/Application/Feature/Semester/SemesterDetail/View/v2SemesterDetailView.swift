//
//  v2SemesterDetailView.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/24/25.
//

import SwiftUI

import ComposableArchitecture
import YDS_SwiftUI

struct v2SemesterDetailView: View {
    @Bindable var store: StoreOf<SemesterDetailReducer>

    @State private var mainViewScrollState: SemesterTab.ID?
    @State private var tabBarScrollState: SemesterTab.ID?
    @State private var progress: CGFloat = .zero

    var body: some View {

        VStack(spacing: 0) {
            TabView(tabs: $store.tabs,
                    activeTab: $store.activeTab,
                    mainViewScrollState: $mainViewScrollState,
                    tabBarScrollState: $tabBarScrollState,
                    progress: $progress)

            GeometryReader {
                let size = $0.size

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {

                        ForEach(store.tabs) { tab in
                            ScrollView(.vertical) {
                                let tappedSemester = findTappedSemester(
                                    semesterList: store.semesterList,
                                    tabId: tab.id
                                )
                                if let semester = tappedSemester {
                                    TopSummary(gradeSummary: semester)
                                    GradeList(lectures: semester.lectures ?? [])
                                }
                            }
                            .padding(20)
                            .frame(width: size.width, height: size.height)
                            .contentShape(.rect)
                        }
                    }
                    .scrollTargetLayout()
                    .rect { rect in
                        progress = -rect.minX / size.width
                    }
                }
            }
            .scrollPosition(id: $mainViewScrollState)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .onChange(of: mainViewScrollState) { oldValue, newValue in
                if let newValue {
                    debugPrint(newValue)
                    withAnimation(.snappy) {
                        tabBarScrollState = newValue
                        store.activeTab = newValue
                    }
                }
            }
        }
        .onAppear() {
            store.send(.onAppear)
        }
    }

    struct TopSummary: View {
        var gradeSummary: GradeSummary

        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .lastTextBaseline) {
                    Text(String(format: "%.2f", gradeSummary.gpa))
                        .font(YDSFont.display1)
                    Text("/ 4.50")
                        .foregroundColor(YDSColor.textTertiary)
                }
                v2GradeOverView(title: "취득 학점",
                                accentText: "\(gradeSummary.earnedCredit)")
                v2GradeOverView(title: "학기별 석차",
                                accentText: "\(gradeSummary.semesterRank)",
                                subText: "\(gradeSummary.semesterStudentCount)")
                v2GradeOverView(title: "전체 석차",
                                accentText: "\(gradeSummary.overallRank)",
                                subText: "\(gradeSummary.overallStudentCount)")
                Divider()
            }
        }
    }

    struct GradeList: View {
        var lectures: [LectureDetail]

        var body: some View {
            VStack {
                ForEach(lectures, id: \.self.code) { lecture in
                    GradeRowView(lectureDetail: lecture)
                }
            }
        }
    }

    private func findTappedSemester(semesterList: [GradeSummary], tabId: String) -> GradeSummary? {
        let tappedSemesterList = store.semesterList.filter { list in
            let id = "\(list.year)년 \(list.semester)"
            return id == tabId
        }
        return tappedSemesterList.first
    }
}

extension v2SemesterDetailView {

    struct TabView: View {
        @Binding var tabs: [SemesterTab]
        @Binding var activeTab: SemesterTab.ID
        @Binding var mainViewScrollState: SemesterTab.ID?
        @Binding var tabBarScrollState: SemesterTab.ID?
        @Binding var progress: CGFloat

        var body: some View {
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach($tabs) { $tab in
                        Button(action: {
                            withAnimation(.snappy) {
                                activeTab = tab.id
                                tabBarScrollState = tab.id
                                mainViewScrollState = tab.id
                            }
                        }) {
                            Text(formatShortedYear(tab.id))
                                .font(YDSFont.button2)
                                .padding(.vertical, 12)
                                .foregroundStyle(activeTab == tab.id ? .primary : Color.gray)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .rect { rect in
                            tab.size = rect.size
                            tab.minX = rect.minX
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: .init(get: {
                return tabBarScrollState
            }, set: { _ in

            }), anchor: .center)

            .overlay(alignment: .bottom) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(height: 2)

                    let inputRange = tabs.indices.compactMap {
                        return CGFloat($0)
                    }
                    let outputRange = tabs.compactMap {
                        return $0.size.width
                    }
                    let outputPositionRange = tabs.compactMap {
                        return $0.minX
                    }

                    if !(inputRange.isEmpty || outputRange.isEmpty || outputPositionRange.isEmpty) {
                        let indicatorWidth = progress.interpolate(inputRange: inputRange, outputRange: outputRange)
                        let indicatorPosition = progress.interpolate(inputRange: inputRange, outputRange: outputPositionRange)

                        Rectangle()
                            .fill(.primary)
                            .frame(width: indicatorWidth,height: 1.5)
                            .offset(x: indicatorPosition)
                    }
                }
            }
            .safeAreaPadding(.horizontal, 15)
            .scrollIndicators(.hidden)
        }

        private func formatShortedYear(_ id: String) -> String {
            let components = id.split(separator: "년")
            guard let year = components.first, components.count > 1 else {
                return id
            }
            if let year = Int(year) {
                let shortedYear = year % 100
                return "\(shortedYear)년\(components[1])"
            }
            return id
        }
    }

}

#Preview {
    let store = Store(initialState: SemesterDetailReducer.State()) {
        SemesterDetailReducer()
    }
    v2SemesterDetailView(store: store)
}
