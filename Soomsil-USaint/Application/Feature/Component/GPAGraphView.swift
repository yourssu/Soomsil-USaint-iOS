//
//  GPAGraphView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 2/17/25.
//

import SwiftUI

import YDS_SwiftUI

/// 성적 추이 그래프
struct GPAGraphView: View {
    enum GraphType {
        case line
        case bar
    }

    // MARK: - Properties

    private let type: GraphType
    private let semesterList: [GradeSummary]
    private let onDetailTap: (() -> Void)?

    @State var isOnSeasonalSemester: Bool = false

    /// GPA 그래프 구성
    /// - Parameters:
    ///   - type: 그래프 타입
    ///   - semesterList: 학기별 성적 목록
    ///   - onDetailTap: 상세 버튼 액션
    init(
        type: GraphType = .line,
        semesterList: [GradeSummary],
        onDetailTap: (() -> Void)? = nil
    ) {
        self.type = type
        self.semesterList = semesterList
        self.onDetailTap = onDetailTap
    }

    // MARK: - Body

    var body: some View {
        switch type {
        case .line:
            lineGraphView
        case .bar:
            barGraphView
        }
    }
}

// MARK: - View

private extension GPAGraphView {
    var lineGraphView: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack(alignment: .center) {
                Text(TextLiteral.GPAGraphView.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.navy700)

                Spacer()

                Button {
                    isOnSeasonalSemester.toggle()
                } label: {
                    HStack(spacing: 4) {
                        YDSIcon.checkcircleLine
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                        Text(TextLiteral.GPAGraphView.includeSeasonalSemester)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.slate400)
                    }
                    .foregroundStyle(
                        isOnSeasonalSemester ? .blue600 : .slate400
                    )
                }
            }

            GPALineGraphView(
                gpaList: semesterList.sortedAscending()
                    .filter {
                        ($0.semester != GPAGraphConstants.winterSemester
                         && $0.semester != GPAGraphConstants.summerSemester)
                        || isOnSeasonalSemester
                    }
                    .filter { $0.gpa != 0 }
                    .map {
                        GPALineGraphView.GPAInfo(
                            semester: GPAGraphConstants.semesterText(
                                year: $0.year,
                                semester: $0.semester
                            ),
                            gpa: $0.gpa
                        )
                    }
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    var barGraphView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                Text(TextLiteral.GPAGraphView.overallTrendTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.gray850)

                Spacer()

                Button {
                    onDetailTap?()
                } label: {
                    HStack(spacing: 4) {
                        Text(TextLiteral.GPAGraphView.detailButtonTitle)
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.blue600)
                }
                .buttonStyle(.plain)
            }

            GPABarGraphView(
                gpaList: overallGraphInfoList
            )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    var regularSemesterList: [GradeSummary] {
        semesterList.sortedAscending()
            .filter {
                $0.semester != GPAGraphConstants.winterSemester
                && $0.semester != GPAGraphConstants.summerSemester
            }
            .filter { $0.gpa != 0 }
    }

    var overallGraphInfoList: [GPABarGraphView.GPAInfo] {
        regularSemesterList.enumerated().map {
            GPABarGraphView.GPAInfo(
                semester: GPAGraphConstants.academicSemesterText(index: $0.offset),
                gpa: $0.element.gpa,
                isLatest: $0.offset == regularSemesterList.count - 1
            )
        }
    }
}

// MARK: - Constants

enum GPAGraphConstants {
    static let semesterAxisLabel = "semester"
    static let gpaAxisLabel = "gpa"
    static let winterSemester = "겨울학기"
    static let summerSemester = "여름학기"
    static let semesterFormat = "%d년 %@"
    static let shortenedSemesterRegexPattern = #"(\d{2})(\d{2})년\s*(1|여름|2|겨울)\s*학기"#
    static let yAxisValues = [1.5, 3.0, 4.5]
    static let barSpacing: CGFloat = 16
    static let maximumBarWidth: CGFloat = 52

    /// 학기 문구 생성
    /// - Parameters:
    ///   - year: 학년도
    ///   - semester: 학기
    static func semesterText(
        year: Int,
        semester: String
    ) -> String {
        String(format: semesterFormat, year, semester)
    }

    /// 학년 학기 문구 생성
    /// - Parameter index: 학기 순서
    static func academicSemesterText(index: Int) -> String {
        "\(index / 2 + 1)-\(index % 2 + 1)"
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(.backgroundSurface)
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 16) {
            GPAGraphView(
                type: .line,
                semesterList: previewSemesterList
            )
            
            GPAGraphView(
                type: .bar,
                semesterList: previewSemesterList
            )
        }
        .padding(20)
    }
}

private let previewSemesterList: [GradeSummary] = [
    GradeSummary(year: 2023, semester: "1 학기", gpa: 3.7, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.3", grade: .aZero, professorName: "이조은")]),
    GradeSummary(year: 2023, semester: "여름학기", gpa: 4.1, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")]),
    GradeSummary(year: 2023, semester: "2 학기", gpa: 3.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")]),
    GradeSummary(year: 2023, semester: "겨울학기", gpa: 3.8, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.2", grade: .aZero, professorName: "최지우")]),
    
    GradeSummary(year: 2024, semester: "1 학기", gpa: 3.7, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.3", grade: .aZero, professorName: "이조은")]),
    GradeSummary(year: 2024, semester: "2 학기", gpa: 3.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")]),
    GradeSummary(year: 2025, semester: "2 학기", gpa: 4.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")])
]
