//
//  GradeOverView.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/16/25.
//

import SwiftUI

import YDS_SwiftUI

struct GradeOverView: View {

    private let title: String
    private let accentText: String
    private let subText: String?
    
    init(title: String, accentText: String, subText: String? = nil) {
        self.title = title
        self.accentText = accentText
        self.subText = subText
    }
    
    var body: some View {
        HStack {
            Text(transformIfZero(title))
                .font(YDSFont.body1)
                .foregroundColor(.grayText)
            Spacer()
            Text(transformIfZero(accentText))
                .font(YDSFont.subtitle2)
                .foregroundStyle(.titleText)
            if let subText {
                Text("/ \(transformIfZero(subText))")
                    .font(YDSFont.caption0)
                    .foregroundColor(.grayText)
            }
        }
        .padding(.vertical, 5)
    }
}

extension GradeOverView {
    func transformIfZero(_ text: String) -> String {
        return text == "0" ? "-" : text
    }
}

#Preview {
    GradeOverView(title: "전체석차", accentText: "25", subText: "70")
}
