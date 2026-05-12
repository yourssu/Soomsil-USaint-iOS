//
//  ChapelSeatLocationReducer.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/12/26.
//

import Foundation

import ComposableArchitecture

@Reducer
struct ChapelSeatLocationReducer {
    @ObservableState
    struct State {
        var chapelCard: ChapelCard

        var seatLocation: ChapelSeatLocation {
            ChapelSeatLocation(seatPosition: chapelCard.seatPosition)
        }
    }

    enum Action {
        case backButtonTapped
        case infoButtonTapped
    }

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .backButtonTapped:
                return .run { _ in
                    await dismiss()
                }
            case .infoButtonTapped:
                // TODO: 채플 좌석 안내 화면 연결
                return .none
            }
        }
    }
}
