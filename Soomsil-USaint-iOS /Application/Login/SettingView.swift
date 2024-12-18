//
//  SettingView.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/18/24.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var path: [StackView]

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SettingView(path: .constant([]))
}
