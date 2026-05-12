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
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.gray850)
                .padding(20)
                .frame(height: 56)
            
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
    let isEnabled: Bool
    let action: () -> Void
    @State private var isPressed: Bool = false

    init(
        text: String,
        rightItem: RightItem,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.rightItem = rightItem
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.gray850)
                .padding(20)
                .frame(height: 56)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isPressed ? .lightGray : .clear)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            guard isEnabled else { return }
                            isPressed = true
                        }
                        .onEnded { _ in
                            guard isEnabled else { return }
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
                    .tint(.blue)
                    .frame(height: 56)
                    .onChange(of: isPushAuthorizationEnabled.wrappedValue) {
                        action()
                    }
            }
        }
    }
}
