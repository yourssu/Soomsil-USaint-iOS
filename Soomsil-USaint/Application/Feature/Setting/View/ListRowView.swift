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
    case chevron
    case text(String)
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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.adaptiveSecondaryText)
                .padding(.horizontal, 2)
            
            VStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    items[index]

                    if index < items.count - 1 {
                        Rectangle()
                            .fill(Color.adaptiveBorder)
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.adaptiveSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.adaptiveBorder, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
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
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.adaptivePrimaryText)
                .padding(.leading, 16)
                .frame(height: 58)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isPressed ? Color.adaptiveMutedSurface : .clear)
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
                            case .chevron:
                                action()
                            case .none, .text, .toggle:
                                break
                            }
                        }
                )
            
            switch rightItem {
            case .none:
                EmptyView()
            case .chevron:
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.adaptiveSecondaryText)
                    .padding(.trailing, 16)
            case .text(let text):
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.adaptiveSecondaryText)
                    .padding(.trailing, 16)
            case .toggle(let isPushAuthorizationEnabled):
                Toggle("", isOn: isPushAuthorizationEnabled)
                    .labelsHidden()
                    .padding(.trailing, 16)
                    .tint(.blue600)
                    .frame(height: 58)
                    .onChange(of: isPushAuthorizationEnabled.wrappedValue) {
                        action()
                    }
            }
        }
    }
}
