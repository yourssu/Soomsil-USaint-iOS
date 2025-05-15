//
//  ListRowView.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 2/5/25.
//

import SwiftUI

import YDS_SwiftUI

enum RightItem {
    case none
    case toggle(isPushAuthorizationEnabled: Binding<Bool>)
}

struct ListRowView: View {
    let title: String
    let items: [RowView]
        
    init(title: String, items: [RowView]) {
        self.title = title
        self.items = items
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.titleText)
                .padding(20)
                .frame(height: 48)
            
            ForEach(items.indices, id: \.self) { index in
                HStack {
                    items[index]
                }
            }
        }
    }
}

struct RowView: View {
    let text: String
    let rightItem: RightItem
    let action: () -> Void
    @State private var isPressed: Bool = false
    
    var body: some View {
        HStack {
            Text(text)
                .font(YDSFont.button3)
                .foregroundStyle(.titleText)
                .padding(20)
                .frame(height: 48)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isPressed ? .lightGray : .clear)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in
                            isPressed = false
                            switch rightItem {
                            case .none:
                                action()
                            case .toggle(_):
                                break
                            }
                        }
                )
            
            switch rightItem {
            case .none:
                EmptyView()
            case .toggle(let isPushAuthorizationEnabled):
                Toggle("", isOn: isPushAuthorizationEnabled)
                    .labelsHidden()
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .tint(.vPrimary)
                    .frame(height: 48)
                    .onChange(of: isPushAuthorizationEnabled.wrappedValue) {
                        action()
                    }
            }
        }
    }
}
