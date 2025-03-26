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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
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
