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
    let items: [ItemModel]
        
    init(title: String, items: [ItemModel]) {
        self.title = title
        self.items = items
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(YDSFont.subtitle3)
                .foregroundColor(YDSColor.textSecondary)
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

struct ItemModel: View {
    let text: String
    let rightItem: RightItem
    let action: () -> Void
    @State private var isPressed: Bool = false
    
    var body: some View {
        HStack {
            Text(text)
                .font(YDSFont.button3)
                .foregroundColor(YDSColor.textSecondary)
                .padding(20)
                .frame(height: 48)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isPressed ? Color(red: 0.95, green: 0.96, blue: 0.97) : Color.white)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in
                            isPressed = false
                            action()
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
                    .tint(YDSColor.buttonPoint)
                    .frame(height: 48)
                    // TODO: onChange 액션 추가
            }
        }
    }
}
