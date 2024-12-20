//
//  Rusaint_iOSApp.swift
//  Rusaint-iOS
//
//  Created by 이조은 on 12/15/24.
//

import SwiftUI

@main
struct Rusaint_iOSApp: App {

    let viewModel = DefaultSaintHomeViewModel()
    @State private var isLoggedIn: Bool = HomeRepository.shared.hasCachedUserInformation

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: viewModel, isLoggedIn: $isLoggedIn)
        }
    }
}
