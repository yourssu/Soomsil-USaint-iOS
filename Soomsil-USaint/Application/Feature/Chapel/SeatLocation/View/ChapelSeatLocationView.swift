//
//  ChapelSeatLocationView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/12/26.
//

import SwiftUI

import ComposableArchitecture

/// 채플 좌석 위치 화면
struct ChapelSeatLocationView: View {
    // MARK: - Properties

    let store: StoreOf<ChapelSeatLocationReducer>

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 4) {
                    ChapelSeatInfoView(
                        type: .summaryCard,
                        chapelCard: store.chapelCard
                    )

                    ZoomableChapelSeatMapView(seatLocation: store.seatLocation)

                    Text(
                        store.seatLocation.guideText
                    )
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.slate500)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .background(.white)
    }
}

// MARK: - View

private extension ChapelSeatLocationView {
    var headerView: some View {
        HStack(alignment: .center) {
            Button {
                store.send(.backButtonTapped)
            } label: {
                Image("ic_arrow_left_line")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(TextLiteral.ChapelSeatLocationView.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.navy900)

            Spacer()

            Button {
                store.send(.infoButtonTapped)
            } label: {
                Icon.info
                    .renderingMode(.template)
                    .foregroundStyle(.navy900)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(TextLiteral.ChapelSeatLocationView.title)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.slate100)
                .frame(height: 1)
        }
    }
}

// MARK: - Preview

#Preview {
    ChapelSeatLocationView(
        store: Store(
            initialState: ChapelSeatLocationReducer.State(
                chapelCard: ChapelCard(
                    attendance: 5,
                    seatPosition: "H-1-4",
                    floorLevel: 1
                )
            )
        ) {
            ChapelSeatLocationReducer()
        }
    )
}
