//
//  ChapelAttendanceInfoView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import SwiftUI

/// 채플 출석 정보 카드
struct ChapelAttendanceInfoView: View {
    // MARK: - Type

    enum InfoType {
        case semester
        case attended
    }

    // MARK: - Properties

    private let requiredAttendanceCount = 8

    let type: InfoType
    let chapelCard: ChapelCard
    let titleText: String?
    let completedText: String?
    
    private var attendanceCount: Int {
        min(chapelCard.attendance, requiredAttendanceCount)
    }
    
    private var attendancePercent: Int {
        Int((Double(attendanceCount) / Double(requiredAttendanceCount) * 100).rounded())
    }
    
    private var title: String {
        if let titleText {
            return titleText
        }

        switch type {
        case .semester:
            return TextLiteral.ChapelAttendanceInfoView.semesterTitle
        case .attended:
            return TextLiteral.ChapelAttendanceInfoView.attendedTitle
        }
    }

    // MARK: - Init
    
    /// 채플 출석 정보 카드 생성
    ///
    /// - Parameters:
    ///   - type: 카드 디자인 타입
    ///   - chapelCard: 채플 정보 모델
    ///   - titleText: 제목 대체 문구
    ///   - completedText: 수료 완료 대체 문구
    init(
        type: InfoType,
        chapelCard: ChapelCard,
        titleText: String? = nil,
        completedText: String? = nil
    ) {
        self.type = type
        self.chapelCard = chapelCard
        self.titleText = titleText
        self.completedText = completedText
    }

    // MARK: - Body

    @ViewBuilder
    var body: some View {
        if chapelCard.status.isActive {
            switch type {
            case .semester:
                semesterBody
            case .attended:
                attendedBody
            }
        } else {
            completedBody
        }
    }

    // MARK: - Private Views

    private var semesterBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.gray950)

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(String(attendanceCount))
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.blue500)

                    Text(TextLiteral.ChapelAttendanceInfoView.requiredCount(requiredAttendanceCount))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.slate400)
                }
            }

            ProgressView(
                value: Double(attendanceCount),
                total: Double(requiredAttendanceCount)
            )
            .frame(height: 7)
            .progressViewStyle(
                LinearProgressViewStyle(
                    progressColor: .blue500,
                    trackColor: .slate100,
                    height: 8
                )
            )

            HStack(alignment: .center, spacing: 12) {
                Spacer()
                
                Text(TextLiteral.ChapelAttendanceInfoView.attendancePercent(attendancePercent))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.blue500)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var attendedBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.gray950)

                    Text(
                        TextLiteral.ChapelAttendanceInfoView.attendanceSummary(
                            attendanceCount: attendanceCount,
                            requiredAttendanceCount: requiredAttendanceCount
                        )
                    )
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.blue500)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.slate400)
                    .padding(.top, 4)
            }

            ProgressView(
                value: Double(attendanceCount),
                total: Double(requiredAttendanceCount)
            )
            .frame(height: 7)
            .progressViewStyle(
                LinearProgressViewStyle(
                    progressColor: .blue500,
                    trackColor: .slate100,
                    height: 8
                )
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16.5)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var completedBody: some View {
        Text(completedText ?? TextLiteral.ChapelAttendanceInfoView.completedTitle)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.blue500)
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(.buttonSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(.backgroundSurface)
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 16) {
            ChapelAttendanceInfoView(
                type: .semester,
                chapelCard: ChapelCard(
                    attendance: 4,
                    seatPosition: "B-12",
                    floorLevel: 1
                )
            )

            ChapelAttendanceInfoView(
                type: .attended,
                chapelCard: ChapelCard(
                    attendance: 5,
                    seatPosition: "B-12",
                    floorLevel: 1
                )
            )

            ChapelAttendanceInfoView(
                type: .semester,
                chapelCard: ChapelCard.inactive()
            )
        }
        .padding(10)
    }
}
