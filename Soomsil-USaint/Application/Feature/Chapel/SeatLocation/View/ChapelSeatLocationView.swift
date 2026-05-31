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
        .background(Color.adaptiveBackground)
        .navigationTitle(TextLiteral.ChapelSeatLocationView.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    store.send(.backButtonTapped)
                } label: {
                    Image("ic_arrow_left_line")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.adaptivePrimaryText)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.infoButtonTapped)
                } label: {
                    Icon.info
                        .renderingMode(.template)
                        .foregroundStyle(Color.adaptivePrimaryText)
                        .frame(width: 22, height: 22)
                }
                .accessibilityLabel(TextLiteral.ChapelSeatLocationView.title)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
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
}
