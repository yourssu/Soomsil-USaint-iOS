//
//  v2SemesterDetailView.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/15/25.
//

import SwiftUI

import ComposableArchitecture
import Rusaint
import YDS_SwiftUI

struct v2SemesterDetailView: View {
    @Perception.Bindable var store: StoreOf<SemesterDetailReducer>
    
    @State var activeTab: SemesterTab.ID
    @State private var mainViewScrollState: SemesterTab.ID?
    @State private var tabBarScrollState: SemesterTab.ID?
    @State private var progress: CGFloat = .zero
    
    var body: some View {
        WithPerceptionTracking {
                if #available(iOS 17.0, *) {

                ZStack {
                    VStack(spacing: 0) {
                        let tabs = store.tabs

                        SemesterTabView(
                            tabs: tabs,
                            activeTab: $activeTab,
                            mainViewScrollState: $mainViewScrollState,
                            tabBarScrollState: $tabBarScrollState,
                            progress: $progress
                            //                            onTabSelected: { tab in
                            //                                mainViewScrollState = tab
                            //                            }
                        )
                        
                        //                        GeometryReader { proxy in
                        //                            let size = proxy.size
                        ScrollView(.horizontal) {
                            var tabWidth: CGFloat = UIScreen.main.bounds.width
                            LazyHStack(spacing: 0) {
                                ForEach(tabs, id: \.id) { tab in
                                    SemesterDetailContent()
                                        .containerRelativeFrame(.horizontal)
//                                        .containerRelativeFrame(.vertical)
                                        .rect { rect in
                                            tabWidth = rect.width
                                        }
                                }
                            }
                            .scrollTargetLayout()
                            .rect { rect in
                                progress = -rect.minX / tabWidth
                            }
                        }
                        .scrollPosition(id: $mainViewScrollState)
                        .scrollTargetBehavior(.paging)
                        .scrollIndicators(.hidden)
                        .onChange(of: mainViewScrollState) { _, newValue in
                            if let newValue {
                                withAnimation(.snappy) {
                                    activeTab = newValue
                                    tabBarScrollState = newValue
                                }
                            }
                        }
                    }
                }
//                .onAppear {
//                    store.send(.onAppear)
//                }
//                .onChange(of: store.toastMessage) { _, newValue in
//                    if let message = newValue {
//                        YDSToast(message, haptic: .failed)
//                    }
//                }
            }
        }
        
    }
    
    struct SemesterDetailContent: View {
        
        var body: some View {
            ScrollView(.vertical) {
                TopSummary()
                GradeList()
            }
//            .background(Color.blue)
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




extension v2SemesterDetailView {
    
    struct SemesterTabView: View {
        @State var tabs: [SemesterTab]
        @Binding var activeTab: SemesterTab.ID
        @Binding var mainViewScrollState: SemesterTab.ID?
        @Binding var tabBarScrollState: SemesterTab.ID?
        
        @Binding var progress: CGFloat
        
        //        var onTabSelected: (SemesterTab.ID) -> Void
        
        var body: some View {
            
            if #available(iOS 17.0, *) {
                
                ScrollView(.horizontal) {
                    HStack(spacing: 24) {
                        
                        ForEach($tabs, id: \.id) { $tab in
                            Button(action: {
                                withAnimation(.snappy) {
                                    activeTab = tab.id
                                    mainViewScrollState = tab.id
                                    tabBarScrollState = tab.id
                                    //                                    onTabSelected(tab.id)
                                }
                            }) {
                                Text(tab.id)
                                    .padding(.vertical, 14)
                                    .font(YDSFont.button2)
                                    .foregroundStyle(activeTab == tab.id ? YDSColor.bottomBarSelected : YDSColor.bottomBarNormal)
                                    .contentShape(.rect)
                            }
                            .rect { rect in
                                tab.size = rect.size
                                tab.minX = rect.minX
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollPosition(id: .init(get: {
                    return tabBarScrollState
                }, set: { _ in
                }), anchor: .center)
                .overlay(alignment: .bottomLeading) {
                    
                    let inputRange = tabs.indices.compactMap {
                        return CGFloat($0)
                    }
                    let outputRange = tabs.compactMap {
                        return $0.size.width
                    }
                    let outputPositionRange = tabs.compactMap {
                        return $0.minX
                    }
                    let indicatorWidth = progress.interpolate(inputRange: inputRange, outputRange: outputRange)
                    let indicatorPosition = progress.interpolate(inputRange: inputRange, outputRange: outputPositionRange)
                    
                    Rectangle()
                        .fill(YDSColor.bottomBarSelected)
                        .frame(width: indicatorWidth, height: 2)
                        .offset(x: indicatorPosition)
                    
                }
                .safeAreaPadding(.horizontal, 27)
                
            }
        }
    }
}

#Preview {
    let store = Store(initialState: SemesterDetailReducer.State()) {
        SemesterDetailReducer()
    }
    v2SemesterDetailView(store: store, activeTab: store.tabs.first?.id ?? "")
}
