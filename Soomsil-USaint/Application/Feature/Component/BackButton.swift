//
//  BackButton.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 3/26/25.
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image("ic_arrow_left_line")
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    BackButton {}
}
