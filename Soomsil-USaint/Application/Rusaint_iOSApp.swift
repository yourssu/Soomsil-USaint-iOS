//
//  Rusaint_iOSApp.swift
//  Rusaint-iOS
//
//  Created by 이조은 on 12/15/24.
//

import SwiftUI
import BackgroundTasks

import ComposableArchitecture
import FirebaseCore
import Rusaint
import Mixpanel

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        if let token = Bundle.main.object(forInfoDictionaryKey: "MIXPANEL_TEAM_TOKEN") as? String {
            Mixpanel.initialize(token: token, trackAutomaticEvents: true)
        } else {
            assertionFailure("Mixpanel 토큰을 불러올 수 없습니다.")
        }
        return true
    }
}

@main
struct Rusaint_iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @Environment(\.scenePhase) var scenePhase
    
    let store = Store(initialState: AppReducer.State()) { AppReducer() }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .onChange(of: scenePhase) { _, phase in
                    debugPrint("ScenePhase: \(phase)")
                    if phase == .background {
                        store.send(.backgroundTask)
                    }
                }
        }
        .backgroundTask(.appRefresh("soomsilUSaint.com")) {
            await store.send(.backgroundTask)
        }
    }
}
