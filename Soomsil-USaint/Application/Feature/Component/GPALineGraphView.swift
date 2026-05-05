//
//  GPALineGraphView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import Charts
import SwiftUI

struct GPALineGraphView: View {
    // MARK: - GPAInfo

    struct GPAInfo: Hashable {
        let semester: String
        let gpa: Float

        /// 축약 학기 문구
        var shortedSemester: String {
            var result = ""

            do {
                let regex = try NSRegularExpression(
                    pattern: GPAGraphConstants.shortenedSemesterRegexPattern,
                    options: []
                )
                let range = NSRange(location: 0, length: semester.utf16.count)

                if let match = regex.firstMatch(in: semester, options: [], range: range),
                   let yearRange = Range(match.range(at: 2), in: semester),
                   let semesterRange = Range(match.range(at: 3), in: semester) {
                    let year = semester[yearRange]
                    let semester = semester[semesterRange]

                    result = "\(year)-\(semester)"
                }
            } catch {
                print("Error creating regex: \(error)")
            }

            return result
        }
    }

    // MARK: - Properties

    let ySymbols = GPAGraphConstants.yAxisValues
    let gpaList: [GPAInfo]

    // MARK: - Body

    var body: some View {
        Chart {
            ForEach(gpaList, id: \.self) { gpa in
                AreaMark(
                    x: .value(GPAGraphConstants.semesterAxisLabel, gpa.semester),
                    yStart: .value(GPAGraphConstants.gpaAxisLabel, 1.5),
                    yEnd: .value(GPAGraphConstants.gpaAxisLabel, gpa.gpa)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(.linearGradient(
                    colors: [.blue600.opacity(0.02), .blue600.opacity(0.19)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))

                LineMark(
                    x: .value(GPAGraphConstants.semesterAxisLabel, gpa.semester),
                    y: .value(GPAGraphConstants.gpaAxisLabel, gpa.gpa)
                )
                .interpolationMethod(.monotone)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(.blue600)

                PointMark(
                    x: .value(GPAGraphConstants.semesterAxisLabel, gpa.semester),
                    y: .value(GPAGraphConstants.gpaAxisLabel, gpa.gpa)
                )
                .foregroundStyle(.blue600)
                .symbol {
                    Circle()
                        .fill(.blue600)
                        .frame(width: 10, height: 10)
                        .overlay {
                            Circle()
                                .stroke(.white, lineWidth: 2)
                        }
                }
                .annotation(position: .top, spacing: 0) {
                    Text(TextLiteral.GPAGraphView.gpaValue(gpa.gpa))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.blue600)
                }
            }
        }
        .chartXScale(range: .plotDimension(startPadding: -16, endPadding: -16))
        .chartYScale(domain: 1.5...4.5)
        .padding(.top, 16)
        .chartYAxis {
            AxisMarks(position: .leading, values: ySymbols) { axis in
                AxisGridLine()
                AxisValueLabel(TextLiteral.GPAGraphView.axisValue(ySymbols[axis.index]))
                    .font(.system(size: 10, weight: .regular))
            }
        }
        .chartXAxis {
            AxisMarks(values: gpaList.map { $0.semester }) { axis in
                AxisValueLabel {
                    Text("\(gpaList[axis.index].shortedSemester)")
                        .font(.system(size: 11, weight: .medium))
                        .minimumScaleFactor(0.5)
                        .padding(.top, 20)
                }
            }
        }
        .frame(height: 184)
    }
}

// MARK: - Preview

#Preview {
    GPALineGraphView(gpaList: [
        GPALineGraphView.GPAInfo(semester: "2023년 1 학기", gpa: 3.7),
        GPALineGraphView.GPAInfo(semester: "2023년 2 학기", gpa: 3.5),
        GPALineGraphView.GPAInfo(semester: "2024년 1 학기", gpa: 4.5),
        GPALineGraphView.GPAInfo(semester: "2024년 여름학기", gpa: 4.5),
        GPALineGraphView.GPAInfo(semester: "2024년 2 학기", gpa: 3.8)
    ])
    .padding()
    .background(.buttonSurface)
}
