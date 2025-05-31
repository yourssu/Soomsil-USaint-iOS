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
    static var liveValue: ChapelClient = Self(
        fetchChapelCard: {
            @Dependency(\.studentClient) var studentClient: StudentClient
            
            // 1. 세션 생성
            let session = try await studentClient.createSaintSession()
            
            // 2. ChapelApplication 생성
            let chapelApp = try await ChapelApplicationBuilder().build(session: session)
            
            // 3. 현재 학기 정보 가져오기
            let currentYear = UInt32(Calendar.current.component(.year, from: Date()))
            let currentMonth = UInt32(Calendar.current.component(.month, from: Date()))
            let semester: SemesterType = currentMonth <= 6 ? .one : .two
            
            // 4. 채플 정보 가져오기
            let chapelInfo = try await chapelApp.information(year: currentYear, semester: semester)
            
            // 5. ChapelCard 생성
            let attendanceCount = chapelInfo.attendances.filter { $0.attendance == "출석" }.count
            let seatPosition = chapelInfo.generalInformation.seatNumber ?? "정보 없음"
            
            return ChapelCard(attendance: attendanceCount, seatPosition: seatPosition)
        }, getChapelCard: {
            let context = coreDataStack.taskContext()
            let fetchRequest: NSFetchRequest<CDChapelCard> = CDChapelCard.fetchRequest()
            
            do {
                let data = try context.fetch(fetchRequest)
                guard let first = data.first else {
                    return ChapelCard(attendance: 0, seatPosition: "정보 없음")
                }
                
                return ChapelCard(
                    attendance: Int(first.attendance),
                    seatPosition: first.seatPosition ?? "정보 없음"
                )
            } catch {
                print("ChapelCard 조회 실패: \(error.localizedDescription)")
                return ChapelCard(attendance: 0, seatPosition: "정보 없음")
            }
        }, updateChapelCard: { chapelCard in
            let context = coreDataStack.taskContext()
            
            // 기존 데이터 삭제
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDChapelCard.fetchRequest())
            try? context.execute(deleteRequest)
            
            // 새 데이터 생성
            let cdChapelCard = CDChapelCard(context: context)
            cdChapelCard.attendance = Int32(chapelCard.attendance)
            cdChapelCard.seatPosition = chapelCard.seatPosition
            
            context.performAndWait {
                do {
                    try context.save()
                } catch {
                    print("ChapelCard 업데이트 실패: \(error.localizedDescription)")
                }
            }
        }, deleteChapelCard: {
            let context = coreDataStack.taskContext()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDChapelCard.fetchRequest())
            
            try context.execute(deleteRequest)
            try context.save()
        }
    )
    
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
