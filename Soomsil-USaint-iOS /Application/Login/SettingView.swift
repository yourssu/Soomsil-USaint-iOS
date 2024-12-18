//
//  SettingView.swift
//  Soomsil-USaint-iOS
//
//  Created by 이조은 on 12/18/24.
//

import SwiftUI
import YDS_SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var path: [StackView]

    var body: some View {
        VStack(alignment: .leading) {
            Text("설정")
                .font(YDSFont.title2)
                .padding(.top, 8)
                .padding(.leading, 16)
            ButtonList(title: "계정관리", items: ["로그아웃"])
            ToggleList(title: "알림", items: ["알림 받기"])
            ButtonList(title: "약관", items: ["이용약관","개인정보수집 및 허용"])
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("ic_arrow_left_line")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

// MARK: - ButtonList
struct ButtonList: View {
    let title: String
    let items: [String]
    @State private var pressedStates: [Bool]

    init(title: String, items: [String]) {
        self.title = title
        self.items = items
        self._pressedStates = State(initialValue: Array(repeating: false, count: items.count))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(YDSFont.subtitle3)
                .foregroundColor(YDSColor.textSecondary)
                .padding(20)
                .frame(height: 48)

            ForEach(items.indices, id: \.self) { index in
                ButtonItem(
                    text: items[index],
                    action: { print("\(items[index]) tapped") },
                    isPressed: $pressedStates[index]
                )
            }
        }
    }
}

struct ButtonItem: View {
    let text: String
    let action: () -> Void
    @Binding var isPressed: Bool

    var body: some View {
        Text(text)
            .font(YDSFont.button3)
            .foregroundColor(YDSColor.textSecondary)
            .padding(20)
            .frame(height: 48)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isPressed ? Color(red: 0.95, green: 0.96, blue: 0.97) : Color.clear)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}

// MARK: - ToggleList

struct ToggleList: View {
    let title: String
    let items: [String]
    @State private var isOn: [Bool]

    init(title: String, items: [String]) {
        self.title = title
        self.items = items
        self._isOn = State(initialValue: Array(repeating: false, count: items.count))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(YDSFont.subtitle3)
                .foregroundColor(YDSColor.textSecondary)
                .padding(20)
                .frame(height: 48)

            ForEach(items.indices, id: \.self) { index in
                ToggleItem(
                    text: items[index],
                    action: { print("\(items[index]) tapped") },
                    isOn: $isOn[index]
                )
            }
        }
    }
}

struct ToggleItem: View {
    let text: String
    let action: () -> Void
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(text)
                .font(YDSFont.button3)
                .foregroundColor(YDSColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .tint(YDSColor.buttonPoint)
                .onChange(of: isOn) { newValue in
                    action()
                }
        }
        .padding(20)
        .frame(height: 48)
    }
}

#Preview {
    SettingView(path: .constant([]))
}
