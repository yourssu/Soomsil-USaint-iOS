//
//  ViewByTypeViewController.swift
//  Soomsil
//
//  Created by 오동규 on 2022/10/02.
//  Copyright © 2022 Yourssu. All rights reserved.
//

import UIKit
import YDS

final class ErrorViewController: UIViewController {
    private let errorView = ErrorView()
    private let type: ErrorViewType

    init(type: ErrorViewType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        errorView.setText(title: type.title, content: type.content, buttonText: type.buttonText)
        errorView.button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
    }

    override func loadView() {
        self.view = errorView
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func buttonDidTap() {
        switch type {
        case .serviceInspection:
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        case .networkError:
            break
        case .notFounded:
            break
        case .preparingService:
            self.navigationController?.popViewController(animated: true)
        }
    }
}
