//
//  ChapelView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import SwiftUI

import ComposableArchitecture

/// 채플 탭 화면
struct ChapelView: View {
    // MARK: - Properties

    @Bindable var store: StoreOf<ChapelReducer>

    // MARK: - Body

    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            VStack(spacing: 0) {
                headerView

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if store.chapelCard.status.isActive {
                            Button {
                                store.send(.seatCardTapped)
                            } label: {
                                ChapelSeatInfoView(
                                    type: .actionCard,
                                    chapelCard: store.chapelCard
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        ChapelAttendanceInfoView(
                            type: .semester,
                            chapelCard: store.chapelCard,
                            titleText: TextLiteral.ChapelView.remainingAttendanceTitle
                        )
                    }
                    .padding(.horizontal, 29)
                    .padding(.vertical, 8)
                }

                Spacer(minLength: 0)

                attendanceArea
            }
            .background(.white)
            .toolbar(.hidden, for: .navigationBar)
        } destination: { store in
            switch store.case {
            case .seatLocation(let store):
                ChapelSeatLocationView(store: store)
            }
        }
    }
}

// MARK: - View

private extension ChapelView {
    var headerView: some View {
        HStack(alignment: .center) {
            Text(TextLiteral.ChapelView.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.gray950)

            Spacer()

            Button {
                store.send(.infoButtonTapped)
            } label: {
                Icon.info
                    .renderingMode(.template)
                    .foregroundStyle(.gray500)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(TextLiteral.ChapelView.title)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    var attendanceArea: some View {
        VStack(spacing: 8) {
            Button {
                store.send(.attendanceButtonTapped)
            } label: {
                HStack(spacing: 8) {
                    Icon.qr
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 18)

                    Text(TextLiteral.ChapelView.attendanceButtonTitle)
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.gray950)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            Text(TextLiteral.ChapelView.attendanceGuide)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.gray500)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
}

// MARK: - Preview

#Preview {
    ChapelView(
        store: Store(
            initialState: ChapelReducer.State(
                chapelCard: ChapelCard(
                    attendance: 3,
                    seatPosition: "B-12",
                    floorLevel: 1
                )
            )
        ) {
            ChapelReducer()
        }
    )
}
