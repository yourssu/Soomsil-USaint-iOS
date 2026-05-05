//
//  LinearProgressViewStyle.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import SwiftUI

/// 선형 프로그래스 스타일
struct LinearProgressViewStyle: ProgressViewStyle {
    // MARK: - Properties
    
    let progressColor: Color
    let trackColor: Color
    let height: CGFloat

    // MARK: - Init

    /// 선형 프로그래스 스타일 생성
    ///
    /// - Parameters:
    ///   - progressColor: 진행 색상
    ///   - trackColor: 트랙 색상
    ///   - height: 프로그래스 높이
    init(
        progressColor: Color,
        trackColor: Color,
        height: CGFloat
    ) {
        self.progressColor = progressColor
        self.trackColor = trackColor
        self.height = height
    }

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(trackColor)
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(progressColor)
                    .frame(
                        width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0),
                        height: height
                    )
            }
        }
        .frame(height: height)
    }
}


#Preview {
    ProgressView(value: 0.6, total: 1.0)
        .frame(width: 300)
        .progressViewStyle(
            LinearProgressViewStyle(
                progressColor: .blue600,
                trackColor: .slate100,
                height: 8
            )
        )
        .padding()
}
