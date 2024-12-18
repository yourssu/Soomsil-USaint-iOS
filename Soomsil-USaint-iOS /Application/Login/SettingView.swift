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
            YDSList(hasSubHeader: true, subHeaderText: "계정관리", items: [YDSListItem(text: "로그아웃")])
            YDSList(hasSubHeader: true, subHeaderText: "알림", items: [YDSListItem(text: "알림 받기", toggle: true)])
            YDSList(hasSubHeader: true, subHeaderText: "약관", items: [YDSListItem(text: "이용약관"), YDSListItem(text: "개인정보수집 및 허용")])
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

#Preview {
    SettingView(path: .constant([]))
}
