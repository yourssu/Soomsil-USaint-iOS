//
//  View+TransparentFullScreenCover.swift
//  Soomsil
//
//  Created by 정종인 on 2023/06/13.
//  Copyright © 2023 Yourssu. All rights reserved.
//

import SwiftUI

struct TransparentBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension View {
    func transparentFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        content: @escaping () -> Content
    ) -> some View {
        fullScreenCover(isPresented: isPresented) {
            ZStack {
                content()
            }
            .background(TransparentBackground())
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
}
