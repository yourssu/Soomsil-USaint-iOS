//
//  MainTabReducer.swift
//  Soomsil-USaint
//

import Foundation

import ComposableArchitecture

@Reducer
struct MainTabReducer {
    @ObservableState
    struct State {
        var selectedTab: MainTabItem = .home
        var homeState: HomeReducer.State
        var chapelState: ChapelReducer.State
        var settingState: SettingReducer.State = SettingReducer.State()

        init(studentInfo: StudentInfo, totalReportCard: TotalReportCard, chapelCard: ChapelCard) {
            homeState = HomeReducer.State(
                studentInfo: studentInfo,
                totalReportCard: totalReportCard,
                chapelCard: chapelCard
            )
            chapelState = ChapelReducer.State(chapelCard: chapelCard)
        }
    }

    enum Action {
        case tabSelected(MainTabItem)
        case home(HomeReducer.Action)
        case chapel(ChapelReducer.Action)
        case setting(SettingReducer.Action)
        case notificationOpened(USaintNotificationRoute)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            case .home(.chapelAttendancePressed):
                state.selectedTab = .chapel
                return .none
            case .home(.getChapelDataResponse(.success(let chapelCard))):
                state.chapelState.updateChapelCard(chapelCard)
                return .none
            case .notificationOpened(.chapel):
                state.selectedTab = .chapel
                return .none
            case .notificationOpened(.notification):
                state.selectedTab = .notification
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.homeState, action: \.home) {
            HomeReducer()
        }
        Scope(state: \.chapelState, action: \.chapel) {
            ChapelReducer()
        }
        Scope(state: \.settingState, action: \.setting) {
            SettingReducer()
        }
    }
}
