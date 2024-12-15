//
//  ErrorView.swift
//  Soomsil
//
//  Created by 오동규 on 2022/10/31.
//  Copyright © 2022 Yourssu. All rights reserved.
//

import UIKit
import YDS

final public class ErrorView: UIView {
    private let ppussungImageView = UIImageView()
    private let titleLabel = YDSLabel()
    private let contentLabel = YDSLabel()
    private(set) lazy var button = YDSBoxButton()
    private let labelStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setProperties()
        setViewHierarchy()
        setLayouts()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setText(title: String, content: String, buttonText: String) {
        titleLabel.text = title
        contentLabel.text = content
        button.text = buttonText
    }
}

extension ErrorView {
    private func setProperties() {
        self.backgroundColor = YDSColor.bgNormal

        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        labelStackView.alignment = .fill

        ppussungImageView.image = UIImage(named: "ppussung")
        ppussungImageView.contentMode = .scaleAspectFit

        titleLabel.style = .subtitle1
        titleLabel.textAlignment = .center
        titleLabel.textColor = YDSColor.textSecondary
        titleLabel.numberOfLines = 1

        contentLabel.style = .body1
        contentLabel.textAlignment = .center
        contentLabel.textColor = YDSColor.textTertiary
        contentLabel.numberOfLines = 2

        button.type = .filled
        button.rounding = .r8
        button.size = .extraLarge
    }

    private func setViewHierarchy() {
        addSubview(ppussungImageView)
        addSubview(labelStackView)
        addSubview(button)

        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(contentLabel)
    }

    private func setLayouts() {
        ppussungImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(labelStackView.snp.top).inset(2)
            $0.size.equalTo(166)
        }

        labelStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            $0.centerY.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }

        button.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(32)
            $0.leading.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }
}
