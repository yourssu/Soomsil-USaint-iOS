//
//  ErrorViewRepresent.swift
//  Soomsil
//
//  Created by 정종인 on 6/2/24.
//  Copyright © 2024 Yourssu. All rights reserved.
//

import SwiftUI

struct ErrorViewControllerRepresent: UIViewControllerRepresentable {
    let type: ErrorViewType

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ErrorViewController(type: type)
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
