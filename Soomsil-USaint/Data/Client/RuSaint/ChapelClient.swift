//
//  ChapelClient.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 6/1/25.
//

import CoreData
import ComposableArchitecture
import Rusaint

@DependencyClient
struct ChapelClient {
    static let coreDataStack: CoreDataStack = .shared
    
    var fetchChapelCard: @Sendable () async throws -> ChapelCard
    
    var getChapelCard: @Sendable () async throws -> ChapelCard
    
    var updateChapelCard: @Sendable (_ chapelCard: ChapelCard) async throws -> Void
    
    var deleteChapelCard: @Sendable () async throws -> Void
}

extension DependencyValues {
    var chapelClient: ChapelClient {
        get { self[ChapelClient.self] }
        set { self[ChapelClient.self] = newValue }
    }
}

extension ChapelClient: DependencyKey {
    static var liveValue: ChapelClient {
        <#code#>
    }
    
    static let previewValue: ChapelClient = Self(
        fetchChapelCard: {
            return ChapelCard(attendance: 2, seatPosition: "E-10-4")
        }, getChapelCard: {
            ChapelCard(attendance: 10, seatPosition: "A-3-2")
        }, updateChapelCard: { chapelCard in
            return
        }, deleteChapelCard: {
            return
        }
    )
    
    static let testValue: ChapelClient = previewValue
}
