//
//  RectKey.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/16/25.
//

import SwiftUI

struct RectKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func rect(completion: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader { proxy in
                    if #available(iOS 17.0, *) {
                        Color.clear
                            .preference(key: RectKey.self,
                                        value: proxy.frame(in: .scrollView(axis: .horizontal)))
                            .onPreferenceChange(RectKey.self, perform: completion)
                    } else {

                    }
                }
            }
    }
}
