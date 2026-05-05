//
//  ChapelSeatInfoView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import SwiftUI

/// 채플 좌석 정보 카드
struct ChapelSeatInfoView: View {
    // MARK: - Type

    enum InfoType {
        case summaryCard
        case actionCard
    }

    // MARK: - Properties

    let type: InfoType
    let chapelCard: ChapelCard

    private var seatPosition: String {
        chapelCard.seatPosition.components(separatedBy: .whitespaces).joined()
    }

    private var seatZone: String {
        guard let zone = seatPosition
            .split(separator: Character(TextLiteral.ChapelSeatInfoView.zoneSeparator))
            .first else {
            return TextLiteral.ChapelSeatInfoView.defaultZone
        }
        return String(zone)
    }
    
    private var seatDescription: String {
        TextLiteral.ChapelSeatInfoView.seatDescription(
            floorLevel: chapelCard.floorLevel,
            seatZone: seatZone
        )
    }

    // MARK: - Init

    /// 채플 좌석 정보 카드 생성
    ///
    /// - Parameters:
    ///   - type: 카드 디자인 타입
    ///   - chapelCard: 채플 정보 모델
    init(
        type: InfoType,
        chapelCard: ChapelCard
    ) {
        self.type = type
        self.chapelCard = chapelCard
    }

    // MARK: - Body

    var body: some View {
        switch type {
        case .summaryCard:
            summaryCardBody
        case .actionCard:
            actionCardBody
        }
    }

    // MARK: - Private Views

    private var summaryCardBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(TextLiteral.ChapelSeatInfoView.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.slate600)

            Text(seatPosition)
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(.blue500)

            Text(seatDescription)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.slate600)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var actionCardBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(TextLiteral.ChapelSeatInfoView.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))

            Text(seatPosition)
                .font(.system(size: 72, weight: .black))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Divider()
                .overlay(.white.opacity(0.16))

            HStack(alignment: .center, spacing: 12) {
                Text(seatDescription)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Spacer()

                HStack(spacing: 4) {
                    Text(TextLiteral.ChapelSeatInfoView.locationButtonTitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(.blue500)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(.backgroundSurface)
            .ignoresSafeArea()

        VStack(spacing: 24) {
            ChapelSeatInfoView(
                type: .summaryCard,
                chapelCard: ChapelCard(
                    attendance: 5,
                    seatPosition: "B-12",
                    floorLevel: 1
                )
            )
            ChapelSeatInfoView(
                type: .actionCard,
                chapelCard: ChapelCard(
                    attendance: 5,
                    seatPosition: "B-12",
                    floorLevel: 1
                )
            )
        }
        .padding(20)
    }
}
