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
    
    @State private var tabs: [TabModel] = [
        .init(id: TabModel.Tab.first),
        .init(id: TabModel.Tab.second),
        .init(id: TabModel.Tab.third),
        .init(id: TabModel.Tab.fourth),
        .init(id: TabModel.Tab.fifth),
        .init(id: TabModel.Tab.sixth)
    ]
    
    @State private var activeTab: TabModel.Tab = .first
    @State private var mainViewScrollState: TabModel.Tab?
    @State private var tabBarScrollState: TabModel.Tab?
    @State private var progress: CGFloat = .zero
    
    var body: some View {
        if #available(iOS 17.0, *) {
            
            VStack(spacing: 0) {
                
                /// Tab View
                SemesterTabView(tabs: $tabs,
                                activeTab: $activeTab,
                                progress: $progress,
                                tabBarScrollState: $tabBarScrollState,
                                onTabSelected: { tab in
                                    mainViewScrollState = tab
                                }
                )
                
        
                
                /// Main View
                GeometryReader {
                    let size = $0.size
                    
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0) {
                            ForEach(tabs) { tab in
                                
                                /// Top Summary View
                                VStack {
                                    Text("")
                                }
                                
                                
                                /// Grade List View
                               
                            }
                        }
                        .scrollTargetLayout()
                        .rect { rect in
                            progress = -rect.minX / size.width
                        }
                        .background(Color.green)
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
            
        } else {
            
        }
    }
}

extension v2SemesterDetailView {
    
    
    
    struct SemesterTabView: View {
        @Binding var tabs: [TabModel]
        @Binding var activeTab: TabModel.Tab
        @Binding var progress: CGFloat
        @Binding var tabBarScrollState: TabModel.Tab?
        
        var onTabSelected: (TabModel.Tab) -> Void
        
        var body: some View {
            if #available(iOS 17.0, *) {
                
                ScrollView(.horizontal) {
                    HStack(spacing: 24) {
                        ForEach($tabs) { $tab in
                            Button(action: {
                                withAnimation(.snappy) {
                                    activeTab = tab.id
                                    tabBarScrollState = tab.id
                                    onTabSelected(tab.id)
                                }
                            }) {
                                Text(tab.id.rawValue)
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
                    
                    let inputRange = tabs.indices.compactMap { return CGFloat($0) }
                    let outputRange = tabs.compactMap { return $0.size.width }
                    let outputPositionRange = tabs.compactMap { return $0.minX }
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
    v2SemesterDetailView()
}
