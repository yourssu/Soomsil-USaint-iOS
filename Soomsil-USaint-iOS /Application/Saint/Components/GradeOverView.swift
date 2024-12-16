//
//  GradeOverView.swift
//  Soomsil
//
//  Created by 정종인 on 2023/09/09.
//  Copyright © 2023 Yourssu. All rights reserved.
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
            Text(title)
                .font(Font(YDSFont.body1))
                .foregroundColor(Color(YDSColor.textTertiary))
            Spacer()
            Text(accentText)
                .font(Font(YDSFont.subtitle2))
            if let subText {
                Text("/ \(subText)")
                    .font(Font(YDSFont.caption0))
                    .foregroundColor(Color(YDSColor.textTertiary))
            }
        }
    }
}

struct GradeOverView_Previews: PreviewProvider {
    static var previews: some View {
        GradeOverview(title: "title", accentText: "accent")
    }
}
