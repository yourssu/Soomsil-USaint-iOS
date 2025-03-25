//
//  Home.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/24/25.
//

import SwiftUI

import ComposableArchitecture
import YDS_SwiftUI

struct Home: View {
    @Perception.Bindable var store: StoreOf<SemesterDetailReducer>

    @State var mainViewScrollState: SemesterTab.ID?
    @State var tabBarScrollState: SemesterTab.ID?
    @State var progress: CGFloat = .zero
    
    var body: some View {
        if #available(iOS 17.0, *) {
            WithPerceptionTracking {
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
                                        SemesterDetailContent()
                                    }
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
        }
    }

    struct SemesterDetailContent: View {
        
        var body: some View {
            ScrollView(.vertical) {
                TopSummary()
                GradeList()
            }
        }
    }
    
    struct TopSummary: View {
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .lastTextBaseline) {
                    Text("4.12")
                        .font(YDSFont.display1)
                    Text("/ 4.50")
                        .foregroundColor(YDSColor.textTertiary)
                }
                v2GradeOverView(title: "취득 학점", accentText: "17")
                v2GradeOverView(title: "학기별 석차", accentText: "15", subText: "55")
                v2GradeOverView(title: "전체 석차", accentText: "25", subText: "70")
                Divider()
            }
        }
    }
    
    struct GradeList: View {
        var grs: [LectureDetail] = [
            .init(code: "1", title: "Academic Writing in English1", credit: 4.0, score: "2.0", grade: .bPlus, professorName: "Jessica Cahill"),
            .init(code: "2", title: "한반도평화와통일", credit: 2.0, score: "1.0", grade: .pass, professorName: "조은희"),
            .init(code: "3", title: "컴퓨팅적사고", credit: 3.0, score: "4.0", grade: .aPlus, professorName: "서유화"),
            .init(code: "4", title: "사고와표현", credit: 4.0, score: "2.6", grade: .bZero, professorName: "김범수"),
            .init(code: "5", title: "물리및실험", credit: 5.0, score: "4.5", grade: .aPlus, professorName: "이재환, 이순녀"),
            .init(code: "6", title: "CHAPEL", credit: 6.0, score: "0", grade: .fail, professorName: "조은식")
        ]
        
        var body: some View {
            VStack {
                ForEach(grs, id: \.self.code) { grade in
                    
                    GradeRowView(lectureDetail: grade)
                    
                }
            }
        }
    }
    

}

extension Home {
    
    struct TabView: View {
        @Binding var tabs: [SemesterTab]
        @Binding var activeTab: SemesterTab.ID
        @Binding var mainViewScrollState: SemesterTab.ID?
        @Binding var tabBarScrollState: SemesterTab.ID?
        @Binding var progress: CGFloat
        
        var body: some View {
            if #available(iOS 17.0, *) {
                
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
                                Text(tab.id)
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
                                .offset(x: indicatorPosition)                        }
                        
                    }
                }
                
                
                .safeAreaPadding(.horizontal, 15)
                .scrollIndicators(.hidden)
            }
        }
    }
}

#Preview {

    let store = Store(initialState: SemesterDetailReducer.State()) {
        SemesterDetailReducer()
    }
    Home(store: store)
}
