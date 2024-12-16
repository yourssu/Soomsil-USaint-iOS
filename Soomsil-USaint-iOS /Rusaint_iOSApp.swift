//
//  Rusaint_iOSApp.swift
//  Rusaint-iOS
//
//  Created by 이조은 on 12/15/24.
//

import SwiftUI

@main
struct Rusaint_iOSApp: App {
    @StateObject private var viewModel = DefaultSaintHomeViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SaintHomeView(viewModel: viewModel)
            }
        }
    }
}
