//
//  SplashReducer.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 2/27/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct SplashReducer {
    @ObservableState
    struct State {
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action {
        case alert(PresentationAction<Alert>)
        case checkMinimumVersion
        case checkMinimumVersionResponse(Result<String, Error>)
        case initialize
        case initResponse(Result<(StudentInfo, TotalReportCard, ChapelCard), Error>)
        
        enum Alert: Equatable {
            case confirmTapped
            case moveAppStoreTapped
        }
    }
    
    @Dependency(\.remoteConfigClient) var remoteConfigClient
    @Dependency(\.gradeClient) var gradeClient
    @Dependency(\.studentClient) var studentClient
    @Dependency(\.chapelClient) var chapelClient
    @Dependency(\.openURL) var openURL
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(.confirmTapped)):
                return .none
            case .alert(.presented(.moveAppStoreTapped)):
                return .run { _ in
                    await openURL(URL(string: "itms-apps://itunes.apple.com/app/id1601044486")!)
                }
            case .checkMinimumVersion:
                return .run { send in
                    await send(.checkMinimumVersionResponse(Result {
                        return try await remoteConfigClient.getMinimumVersion()
                    }))
                }
            case .checkMinimumVersionResponse(.success(let minimumVersion)):
                if checkMinimumVersion(minimum: minimumVersion) {
                    return .send(.initialize)
                } else {
                    state.alert = AlertState(
                        title: { TextState("앱 업데이트가 있어요") },
                        actions: {
                            ButtonState(action: .send(.moveAppStoreTapped)) {
                                TextState("스토어로 이동하기")
                            }
                        },
                        message: {
                            TextState("원활한 서비스 이용을 위해\n업데이트가 필요해요")
                        }
                    )
                    return .none
                }
            case .checkMinimumVersionResponse(.failure(let error)):
                debugPrint(error.localizedDescription)
                state.alert = AlertState(
                    title: { TextState("네트워크 에러") },
                    actions: {
                        ButtonState(action: .send(.confirmTapped)) {
                            TextState("확인")
                        }
                    },
                    message: {
                        TextState("버전 정보를 불러오는 데 실패했습니다.\n네트워크 상태를 확인한 후 다시 시도해주세요.")
                    }
                )
                return .none
            case .initialize:
                return .run { send in
                    await send(.initResponse(Result {
                        let info = try await studentClient.getStudentInfo()
                        let card = try await gradeClient.getTotalReportCard()
                        let chapel = try await chapelClient.getChapelCard()
                        return (info, card, chapel)
                    }))
                }
            default:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    func checkMinimumVersion(minimum minimumVersion: String) -> Bool {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        let current = currentVersion.split(separator: ".").map { Int($0) ?? 0 }
        let minimum = minimumVersion.split(separator: ".").map { Int($0) ?? 0 }
        
        return (current[0], current[1], current[2]) >= (minimum[0], minimum[1], minimum[2])
    }
}
