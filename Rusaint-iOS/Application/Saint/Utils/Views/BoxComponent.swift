//
//  BoxComponent.swift
//  Soomsil
//
//  Created by 정종인 on 2023/06/13.
//  Copyright © 2023 Yourssu. All rights reserved.
//

import SwiftUI
import YDS

struct Box: View {
    var title: String
    var accentText: String
    var subText: String?
    var isWideView: Bool = false
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10.0) {
                Text(title)
                    .font(Font(YDSFont.subtitle2))
                HStack(alignment: .bottom) {
                    Text(accentText)
                        .font(Font(YDSFont.title1))
                    if let subText {
                        (Text("/ ") + Text(subText))
                            .font(Font(YDSFont.subtitle1))
                            .foregroundColor(Color(YDSColor.textTertiary))
                    }
                    if isWideView {
                        Spacer()
                    }
                }
            }
            .padding(.trailing, 30)
        }
        .background(Color(YDSColor.monoItemBG))
        .cornerRadius(8.0)
    }
}
