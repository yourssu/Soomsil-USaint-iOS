//
//  ChapelReducer.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/12/26.
//

import Foundation

import ComposableArchitecture

@Reducer
struct ChapelReducer {
    @Reducer
    enum Path {
        case seatLocation(ChapelSeatLocationReducer)
    }

    @ObservableState
    struct State {
        var chapelCard: ChapelCard
        var path = StackState<Path.State>()

        init(chapelCard: ChapelCard) {
            self.chapelCard = chapelCard
        }

        mutating func updateChapelCard(_ chapelCard: ChapelCard) {
            self.chapelCard = chapelCard
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case path(StackActionOf<Path>)
        case infoButtonTapped
        case seatCardTapped
        case attendanceButtonTapped
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .path:
                return .none
            case .infoButtonTapped:
                // TODO: 채플 안내 화면 연결
                return .none
            case .seatCardTapped:
                state.path.append(.seatLocation(ChapelSeatLocationReducer.State(chapelCard: state.chapelCard)))
                return .none
            case .attendanceButtonTapped:
                // TODO: 출석 인증 QR 스캔 연결
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
