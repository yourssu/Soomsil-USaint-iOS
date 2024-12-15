//
//  TapToHideKeyboard.swift
//  Rusaint-iOS
//
//  Created by 이조은 on 12/16/24.
//

import SwiftUI

struct TapToHideKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func tapToHideKeyboard() -> some View {
        modifier(TapToHideKeyboard())
    }
}
