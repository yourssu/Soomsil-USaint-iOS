//
//  GradeOverview.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/16/24.
//

import SwiftUI
import YDS

struct GradeOverview: View {
    private var title: String
    private var accentText: String
    private var subText: String?
    init(title: String, accentText: String, subText: String? = nil) {
        self.title = title
        self.accentText = accentText
        self.subText = subText
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(transformIfZero(title))
                .font(Font(YDSFont.body1))
                .foregroundColor(Color(YDSColor.textTertiary))
            Spacer()
            Text(transformIfZero(accentText))
                .font(Font(YDSFont.subtitle2))
            if let subText {
                Text("/ \(transformIfZero(subText))")
                    .font(Font(YDSFont.caption0))
                    .foregroundColor(Color(YDSColor.textTertiary))
            }
        }
    }
    
    private func transformIfZero(_ text: String) -> String {
        return text == "0" ? "-" : text
    }
}

struct GradeOverView_Previews: PreviewProvider {
    static var previews: some View {
        GradeOverview(title: "title", accentText: "accent")
    }
}

