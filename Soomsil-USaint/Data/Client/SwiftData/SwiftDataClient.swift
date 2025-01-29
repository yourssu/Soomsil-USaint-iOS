//
//  SwiftDataClient.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 1/29/25.
//

import Foundation
import SwiftData

import ComposableArchitecture

@DependencyClient
struct SwiftDataClient {
    var fetchTotalReportCard: () throws -> TotalReportCardTestModel?
    
    static let container: ModelContainer = {
        let schema = Schema([Lecture.self, Semester.self, TotalReportCardTestModel.self])
        let modelConfiguration = ModelConfiguration(for: Lecture.self, Semester.self, TotalReportCardTestModel.self, isStoredInMemoryOnly: false)
        let configuration = ModelConfiguration(cloudKitDatabase: .none)
        return try! ModelContainer(for: schema, configurations: [modelConfiguration, configuration])
    }()
}

extension DependencyValues {
    var swiftDataClient: SwiftDataClient {
        get { self[SwiftDataClient.self] }
        set { self[SwiftDataClient.self] = newValue}
    }
}

extension SwiftDataClient: DependencyKey {
    static let liveValue: SwiftDataClient = Self(
        fetchTotalReportCard: {
            let context = ModelContext(container)
            let descripter = FetchDescriptor<TotalReportCardTestModel>()
            return try context.fetch(descripter).first;
        }
    )
}
