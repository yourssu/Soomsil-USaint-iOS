//
//  GradeRowView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import SwiftUI

struct GradeRowView: View {
    // MARK: - Type
    
    enum DisplayType {
        case compact
        case detailed
    }

    // MARK: - Properties

    private let type: DisplayType
    private let title: String
    private let professorName: String
    private let credit: Double
    private let grade: Grade

    /// 과목 성적 row 구성
    /// - Parameters:
    ///   - type: row 표시 타입
    ///   - lectureDetail: 과목 성적 모델
    init(
        type: DisplayType = .detailed,
        lectureDetail: LectureDetail
    ) {
        self.type = type
        self.title = lectureDetail.title
        self.professorName = lectureDetail.professorName
        self.credit = lectureDetail.credit
        self.grade = lectureDetail.grade
    }

    // MARK: - Body

    var body: some View {
        switch type {
        case .compact:
            compactView
        case .detailed:
            detailedView
        }
    }
}

// MARK: - View

private extension GradeRowView {
    var compactView: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.orange500)
                .frame(width: 8, height: 8)

            TitleText(
                title: title,
                color: .navy700
            )

            CourseMetadataView(
                professorName: sanitizedProfessorName,
                credit: credit,
                style: .inline
            )

            Spacer(minLength: 12)

            GradeBadgeView(
                grade: grade,
                type: .compact,
                foregroundColor: .orange500,
                backgroundColor: .orange50
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    var detailedView: some View {
        HStack(spacing: 12) {
            GradeBadgeView(
                grade: grade,
                type: .detailed,
                foregroundColor: .blue600,
                backgroundColor: .blue50
            )

            VStack(alignment: .leading, spacing: 4) {
                TitleText(
                    title: title,
                    color: .gray950
                )

                CourseMetadataView(
                    professorName: sanitizedProfessorName,
                    credit: credit,
                    style: .combined
                )
            }

            Spacer(minLength: 12)

            GradeBadgeView(
                grade: grade,
                type: .detailed,
                foregroundColor: .blue600,
                backgroundColor: .blue50
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.gray150)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    var sanitizedProfessorName: String {
        let nonBreakingSpace = " "

        if professorName == nonBreakingSpace {
            return ""
        }

        return professorName
    }
}

// MARK: - Subviews

private extension GradeRowView {
    struct TitleText: View {
        let title: String
        let color: Color

        /// 과목명 텍스트 구성
        /// - Parameters:
        ///   - title: 과목명
        ///   - color: 텍스트 색상
        init(
            title: String,
            color: Color
        ) {
            self.title = title
            self.color = color
        }

        var body: some View {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
    }

    struct CourseMetadataView: View {
        enum Style {
            case inline
            case combined
        }

        let professorName: String
        let credit: Double
        let style: Style

        /// 과목 부가 정보 구성
        /// - Parameters:
        ///   - professorName: 교수명
        ///   - credit: 학점
        ///   - style: 표시 타입
        init(
            professorName: String,
            credit: Double,
            style: Style
        ) {
            self.professorName = professorName
            self.credit = credit
            self.style = style
        }

        var body: some View {
            switch style {
            case .inline:
                inlineView
            case .combined:
                combinedView
            }
        }

        private var inlineView: some View {
            HStack(spacing: 10) {
                if !professorName.isEmpty {
                    metadataText(
                        professorName,
                        color: .slate400
                    )
                }

                metadataText(
                    TextLiteral.GradeRowView.credit(credit),
                    color: .slate200
                )
            }
        }

        private var combinedView: some View {
            metadataText(
                TextLiteral.GradeRowView.detailText(
                    professorName: professorName,
                    credit: credit
                ),
                color: .gray500
            )
        }

        /// 메타 텍스트 구성
        /// - Parameters:
        ///   - text: 표시 문구
        ///   - color: 텍스트 색상
        private func metadataText(
            _ text: String,
            color: Color
        ) -> some View {
            Text(text)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
    }

    struct GradeBadgeView: View {
        let grade: Grade
        let type: DisplayType
        let foregroundColor: Color
        let backgroundColor: Color

        /// 성적 배지 구성
        /// - Parameters:
        ///   - grade: 성적
        ///   - type: 배지 표시 타입
        ///   - foregroundColor: 텍스트 색상
        ///   - backgroundColor: 배경 색상
        init(
            grade: Grade,
            type: DisplayType,
            foregroundColor: Color,
            backgroundColor: Color
        ) {
            self.grade = grade
            self.type = type
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
        }

        var body: some View {
            Text(grade.string)
                .font(.system(size: fontSize, weight: fontWeight))
                .foregroundStyle(foregroundColor)
                .padding(.horizontal, 12)
                .padding(.vertical, verticalPadding)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }

        private var fontSize: CGFloat {
            switch type {
            case .compact:
                return 13
            case .detailed:
                return 12
            }
        }

        private var fontWeight: Font.Weight {
            switch type {
            case .compact:
                return .bold
            case .detailed:
                return .semibold
            }
        }

        private var verticalPadding: CGFloat {
            switch type {
            case .compact:
                return 4
            case .detailed:
                return 12
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        GradeRowView(
            type: .compact,
            lectureDetail: LectureDetail(
                code: "database",
                title: "데이터베이스",
                credit: 3.0,
                score: "PASS",
                grade: .bPlus,
                professorName: "전지훈"
            )
        )

        GradeRowView(
            type: .detailed,
            lectureDetail: LectureDetail(
                code: "digital-media",
                title: "디지털미디어원리",
                credit: 3.0,
                score: "PASS",
                grade: .aMinus,
                professorName: "김서연"
            )
        )
    }
    .padding()
    .background(.backgroundSurface)
}
