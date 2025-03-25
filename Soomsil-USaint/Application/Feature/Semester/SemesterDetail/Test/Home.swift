//
//  Home.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/24/25.
//

import SwiftUI
import ComposableArchitecture

struct Home: View {
    @Perception.Bindable var store: StoreOf<SemesterDetailReducer>

    
//    @State var tabs: [SemesterTab] = []
//    @State var activeTab: SemesterTab.ID = ""
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
                                    Text(tab.id)
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
