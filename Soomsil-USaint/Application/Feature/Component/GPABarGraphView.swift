//
//  GPABarGraphView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import Charts
import SwiftUI

struct GPABarGraphView: View {
    // MARK: - GPAInfo

    struct GPAInfo: Hashable {
        let semester: String
        let gpa: Float
        let isLatest: Bool
    }

    // MARK: - Properties

    let gpaList: [GPAInfo]

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            chart(
                barWidth: calculatedBarWidth(totalWidth: proxy.size.width)
            )
        }
        .frame(height: 116)
    }
}

// MARK: - View

private extension GPABarGraphView {
    /// 막대 그래프 구성
    /// - Parameter barWidth: 막대 너비
    func chart(barWidth: MarkDimension) -> some View {
        Chart {
            ForEach(Array(gpaList.enumerated()), id: \.element) { index, gpa in
                BarMark(
                    x: .value(GPAGraphConstants.semesterAxisLabel, gpa.semester),
                    y: .value(GPAGraphConstants.gpaAxisLabel, gpa.gpa),
                    width: barWidth
                )
                .foregroundStyle(barColor(at: index, isLatest: gpa.isLatest))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .annotation(position: .top, spacing: 6) {
                    if gpa.isLatest {
                        Text(TextLiteral.GPAGraphView.gpaValue(gpa.gpa))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .chartYScale(domain: 0...4.5)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: gpaList.map(\.semester)) { axis in
                AxisTick()
                    .foregroundStyle(.clear)
                AxisValueLabel {
                    if let semester = axis.as(String.self),
                       let gpaInfo = gpaList.first(where: { $0.semester == semester }) {
                        Text(gpaInfo.semester)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(gpaInfo.isLatest ? .black : .slate400)
                    }
                }
            }
        }
        .padding(.top, 16)
        .chartLegend(.hidden)
    }
}

// MARK: - Preview

#Preview {
    GPABarGraphView(gpaList: [
        GPABarGraphView.GPAInfo(semester: "1-1", gpa: 3.7, isLatest: false),
        GPABarGraphView.GPAInfo(semester: "1-2", gpa: 3.5, isLatest: false),
        GPABarGraphView.GPAInfo(semester: "2-1", gpa: 4.5, isLatest: false),
        GPABarGraphView.GPAInfo(semester: "2-2", gpa: 3.8, isLatest: false),
        GPABarGraphView.GPAInfo(semester: "3-1", gpa: 4.21, isLatest: true)
    ])
    .padding()
    .background(.buttonSurface)
}

// MARK: - Helpers

private extension GPABarGraphView {
    /// 막대 너비 계산
    /// - Parameter totalWidth: 부모 전체 너비
    func calculatedBarWidth(totalWidth: CGFloat) -> MarkDimension {
        let itemCount = CGFloat(max(gpaList.count, 1))
        let spacingCount = max(itemCount - 1, 0)
        let totalSpacing = GPAGraphConstants.barSpacing * spacingCount
        let barWidth = (totalWidth - totalSpacing) / itemCount
        let limitedBarWidth = min(barWidth, GPAGraphConstants.maximumBarWidth)

        return .fixed(max(limitedBarWidth, 1))
    }

    /// 막대 색상 반환
    /// - Parameters:
    ///   - index: 막대 순서
    ///   - isLatest: 최신 학기 여부
    func barColor(
        at index: Int,
        isLatest: Bool
    ) -> Color {
        guard !isLatest else {
            return .black
        }

        let colors: [Color] = [
            .blue100,
            .blue200,
            .blue100,
            .blue200
        ]

        return colors[index % colors.count]
    }
}
