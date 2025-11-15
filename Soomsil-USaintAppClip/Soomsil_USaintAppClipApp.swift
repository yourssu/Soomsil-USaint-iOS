//
//  Soomsil_USaintAppClipApp.swift
//  Soomsil-USaintAppClip
//
//  Created by 서준영 on 11/12/25.
//

import SwiftUI

@main
struct Soomsil_USaintAppClipApp: App {
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            if loginViewModel.isLoggedIn {
                HomeView()
            } else {
                LoginView()
                    .environmentObject(loginViewModel)
            }
//            LoginView()
//            HomeView()
            /*
            // FIXME: handleImcomingURL이 필요할까?
//                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
//                    handleIncomingURL(userActivity)
//                }
        }
    }
    
    func handleIncomingURL(_ userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL else {
            print("URL을 받지 못함")
            return
        }
        
        print("App Clip URL 수신: \(incomingURL)")
        
        // URL 컴포넌트 파싱
        guard let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return
        }
        
        print("경로: \(components.path)")
        
        // 쿼리 파라미터가 있다면 출력 (예: ?id=123&name=test)
        if let queryItems = components.queryItems {
            print("쿼리 파라미터:")
            for item in queryItems {
                print("  - \(item.name): \(item.value ?? "없음")")
            }
             */
        }
    }
}
