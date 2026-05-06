//
//  ReportCardView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import SwiftUI

struct ReportCardView: View {
    // MARK: - Type
    
    enum ViewType {
        case overview
        case summary
    }

    // MARK: - Properties

    private let type: ViewType
    private let reportCard: TotalReportCard
    private let lectureCount: Int?

    /// 성적 카드 구성
    /// - Parameters:
    ///   - type: 카드 표시 타입 (overview, summary중 택 1)
    ///   - reportCard: 전체 성적 모델
    ///   - lectureCount: 과목 수
    init(
        type: ViewType = .overview,
        reportCard: TotalReportCard,
        lectureCount: Int? = nil
    ) {
        self.type = type
        self.reportCard = reportCard
        self.lectureCount = lectureCount
    }

    /// 학기 성적 카드 구성
    /// - Parameters:
    ///   - reportCard: 카드 표시 타입
    ///   - semester: 학기 성적 모델
    init(
        reportCard type: ViewType,
        semester: GradeSummary
    ) {
        self.type = type
        self.reportCard = TotalReportCard(
            gpa: semester.gpa,
            earnedCredit: semester.earnedCredit,
            graduateCredit: 4.5,
            generalRank: semester.overallRank,
            overallStudentCount: semester.overallStudentCount
        )
        self.lectureCount = semester.lectures?.count
    }

    // MARK: - Body

    var body: some View {
        switch type {
        case .overview:
            overviewView
        case .summary:
            summaryView
        }
    }
}

// MARK: - View

private extension ReportCardView {
    var overviewView: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 2) {
                Text(TextLiteral.ReportCardView.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(TextLiteral.ReportCardView.totalSubtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(TextLiteral.GPAGraphView.gpaValue(reportCard.gpa))
                    .font(.system(size: 80, weight: .black))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)

                Text(TextLiteral.ReportCardView.maxGPA)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            HStack(spacing: 6) {
                Text(TextLiteral.ReportCardView.currentSemesterButtonTitle)
                Image(systemName: "arrow.right")
                    .frame(width: 14, height: 14)
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.gray950)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.white)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(.gray950)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    var summaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(TextLiteral.ReportCardView.totalGPATitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.gray500)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(TextLiteral.GPAGraphView.gpaValue(reportCard.gpa))
                    .font(.system(size: 40, weight: .black))
                    .foregroundStyle(.white)

                Text(TextLiteral.ReportCardView.maxGPA)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.gray500)
            }

            HStack(spacing: 10) {
                summaryText(
                    title: TextLiteral.ReportCardView.earnedCreditTitle,
                    value: TextLiteral.ReportCardView.credit(reportCard.earnedCredit)
                )

                separator

                if let lectureCount {
                    summaryText(
                        title: TextLiteral.ReportCardView.lectureCountTitle,
                        value: TextLiteral.ReportCardView.lectureCount(lectureCount)
                    )

                    separator
                }

                summaryText(
                    title: TextLiteral.ReportCardView.totalRankTitle,
                    value: TextLiteral.ReportCardView.rank(reportCard.generalRank)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    /// 요약 문구 구성
    /// - Parameters:
    ///   - title: 제목
    ///   - value: 값
    func summaryText(
        title: String,
        value: String
    ) -> some View {
        Text(TextLiteral.ReportCardView.summaryItem(title: title, value: value))
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(.gray500)
    }

    var separator: some View {
        Text(TextLiteral.ReportCardView.summarySeparator)
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(.gray800)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ReportCardView(
                type: .overview,
                reportCard: TotalReportCard(
                    gpa: 3.87,
                    earnedCredit: 11.5,
                    graduateCredit: 188,
                    generalRank: 12,
                    overallStudentCount: 100
                ),
                lectureCount: nil
            )

            ReportCardView(
                type: .summary,
                reportCard: TotalReportCard(
                    gpa: 3.87,
                    earnedCredit: 11.5,
                    graduateCredit: 188,
                    generalRank: 12,
                    overallStudentCount: 100
                ),
                lectureCount: 5
            )

            ReportCardView(
                reportCard: .summary,
                semester: GradeSummary(
                    year: 2025,
                    semester: "1 학기",
                    gpa: 3.87,
                    earnedCredit: 11.5,
                    semesterRank: 12,
                    semesterStudentCount: 100,
                    overallRank: 12,
                    overallStudentCount: 100,
                    lectures: []
                )
            )
        }
        .padding()
    }
    .background(.backgroundSurface)
}
