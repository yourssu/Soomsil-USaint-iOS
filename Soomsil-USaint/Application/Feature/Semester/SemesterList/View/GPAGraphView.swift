//
//  GPAGraphView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 2/17/25.
//

import Charts
import SwiftUI

import YDS_SwiftUI

struct GPAGraphView: View {
    var semesterList: [GradeSummary]
    @State var isOnSeasonalSemester: Bool = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 18) {
            GPAGraph(
                gpaList: semesterList.sortedAscending()
                    .filter {
                        ($0.semester != "겨울학기" && $0.semester != "여름학기")
                        || isOnSeasonalSemester
                    }
                    .filter { $0.gpa != 0 }
                    .map { GPAGraph.GPAInfo(semester: "\($0.year)년 \($0.semester)", gpa: $0.gpa) }
            )
            Button {
                isOnSeasonalSemester.toggle()
            } label: {
                HStack(spacing: 4) {
                    YDSIcon.checkcircleLine
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                    Text("계절학기 포함")
                        .font(YDSFont.button4)
                        .foregroundStyle(.grayText)
                }
                .foregroundStyle(
                    isOnSeasonalSemester
                    ? .vPrimary
                    : .grayText
                )
            }
        }
    }
}

private extension GPAGraphView {
    struct GPAGraph: View {
        struct GPAInfo: Hashable {
            let semester: String
            let gpa: Float
            /// shortedSemester : 차트의 label에 "2023년 1 학기" 문자열을 "23-1" 형태로 축약하여 출력
            var shortedSemester: String {
                var result = ""
                let pattern = #"(\d{2})(\d{2})년\s*(1|여름|2|겨울)\s*학기"#

                do {
                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                    let range = NSRange(location: 0, length: semester.utf16.count)

                    if let match = regex.firstMatch(in: semester, options: [], range: range) {
                        if let yearRange = Range(match.range(at: 2), in: semester),
                           let semesterRange = Range(match.range(at: 3), in: semester) {
                            let year = semester[yearRange]
                            let semester = semester[semesterRange]

                            result = "\(year)-\(semester)"
                        }
                    }
                } catch {
                    print("Error creating regex: \(error)")
                }

                return result
            }
        }
        let ySymbols: [Double] = [0, 1, 2]
        let gpaList: [GPAInfo]
        var trimmedGPAList: [GPAInfo] {
            gpaList.map {
                GPAInfo(
                    semester: $0.semester,
                    gpa: ($0.gpa - 2) < 0 ? 0 : ($0.gpa - 2)
                )
            }
        }

        var body: some View {
            Chart {
                ForEach(trimmedGPAList, id: \.self) { gpa in
                    AreaMark(
                        x: .value("semester", gpa.semester),
                        y: .value("gpa", gpa.gpa)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.vPrimary.opacity(0.5))
                    LineMark(
                        x: .value("semester", gpa.semester),
                        y: .value("gpa", gpa.gpa)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(.vPrimary)
                    .symbol {
                        Circle()
                            .fill(.vPrimary)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .chartYScale(domain: 0...2.5)
            .chartYAxis {
                AxisMarks(position: .leading, values: ySymbols) { axis in
                    AxisGridLine()
                    AxisValueLabel("\(String(format: "%.1F", ySymbols[axis.index] + 2))")
                }
            }
            .chartXAxis {
                AxisMarks(values: gpaList.map { $0.semester }) { axis in
                    AxisValueLabel("\(gpaList[axis.index].shortedSemester)")
                }
            }
            .frame(height: 183)
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    GPAGraphView(semesterList: [
        GradeSummary(year: 2024, semester: "2 학기", gpa: 3.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")]),
         GradeSummary(year: 2024, semester: "1 학기", gpa: 4.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 4.0, score: "3.3", grade: .aZero, professorName: "이조은")]),
        GradeSummary(year: 2024, semester: "여름학기", gpa: 4.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 4.0, score: "3.3", grade: .aZero, professorName: "이조은")]),
        GradeSummary(year: 2023, semester: "1 학기", gpa: 3.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.3", grade: .aZero, professorName: "이조은")])
    ])
}
