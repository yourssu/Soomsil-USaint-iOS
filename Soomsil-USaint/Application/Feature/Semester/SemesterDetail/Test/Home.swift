//
//  Home.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/24/25.
//

import SwiftUI

struct Home: View {
    
    @State var tabs: [SemesterTab]
    @State var activeTab: SemesterTab.ID
    @State var mainViewScrollState: SemesterTab.ID?
    @State var tabBarScrollState: SemesterTab.ID?
    
    var body: some View {
        if #available(iOS 17.0, *) {
            
            TabView(tabs: tabs,
                    activeTab: $activeTab,
                    mainViewScrollState: $mainViewScrollState,
                    tabBarScrollState: $tabBarScrollState)
            
            GeometryReader {
                let size = $0.size
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        
                        ForEach(tabs) { tab in
                            Text(tab.id)
                                .frame(width: size.width, height: size.height)
                                .contentShape(.rect)
                        }
                    }
                    .scrollTargetLayout()
                }
            }
            .scrollPosition(id: $mainViewScrollState)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .onChange(of: mainViewScrollState) { oldValue, newValue in
                if let newValue {
                    withAnimation(.snappy) {
                        tabBarScrollState = newValue
                        activeTab = newValue
                    }
                }
            }
        }
        
    }

    

}

extension Home {
    
    struct TabView: View {
        @State var tabs: [SemesterTab]
        @Binding var activeTab: SemesterTab.ID
        @Binding var mainViewScrollState: SemesterTab.ID?
        @Binding var tabBarScrollState: SemesterTab.ID?
        //
        //        @Binding var progress: CGFloat
        var body: some View {
            if #available(iOS 17.0, *) {
                
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        ForEach(tabs) { tab in
                            Button(action: {
                                withAnimation(.snappy) {
                                    activeTab = tab.id
                                    tabBarScrollState = tab.id
                                    mainViewScrollState = tab.id
                                }
                            }) {
                                Text(tab.id)
                                    .foregroundStyle(activeTab == tab.id ? .primary : Color.gray)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: .init(get: {
                    return tabBarScrollState
                }, set: { _ in
                    
                }), anchor: .center)
                .scrollIndicators(.hidden)
            }
        }
    }
}

#Preview {
    
    var t: [SemesterTab] = [
        .init(id: "2020 1학기"),
        .init(id: "20212021 2학기"),
        .init(id: "2020 2학기"),
        .init(id: "2021 1학기"),
        .init(id: "2021 2학기"),
    ]
    Home(tabs: t, activeTab: t.first!.id)
}
