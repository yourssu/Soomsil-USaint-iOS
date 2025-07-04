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

enum ChapelError: Error {
    case noChapelData        // 채플 정보가 없는 학생
    case networkError(Error) // 네트워크 오류
}

extension ChapelClient: DependencyKey {
    static var liveValue: ChapelClient = Self(
        fetchChapelCard: {
            @Dependency(\.studentClient) var studentClient: StudentClient
            
            do {
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
                let seatPosition = chapelInfo.generalInformation.seatNumber
                let floorLevel = chapelInfo.generalInformation.floorLevel
                
                return ChapelCard(attendance: attendanceCount, seatPosition: seatPosition, floorLevel: floorLevel)
            } catch let error as ChapelError {
                print("catch: error as ChapelError")
                throw error
            } catch let error as URLError {
                print("catch: error as URLError")
                throw ChapelError.networkError(error)
            } catch {
                let errorString = String(describing: error)
                let errorDescription = error.localizedDescription
                
                if errorString.contains("No chapel information provided") ||
                   errorDescription.contains("No chapel information provided") ||
                   errorString.contains("no chapel") ||
                   errorDescription.contains("no chapel") {
                    throw ChapelError.noChapelData
                } else if error is URLError {
                    // 네트워크 관련 에러
                    throw ChapelError.networkError(error)
                } else {
                    // 기타 에러
                    throw ChapelError.networkError(error)
                }
            }
        }, getChapelCard: {
            let context = coreDataStack.taskContext()
            let fetchRequest: NSFetchRequest<CDChapelCard> = CDChapelCard.fetchRequest()
            
            do {
                let data = try context.fetch(fetchRequest)
                guard let first = data.first else {
                    return ChapelCard(attendance: 0, seatPosition: "정보 없음", floorLevel: 0, status: .inactive)
                }
                
                let statusString = first.status ?? "active"
                let status: ChapelStatus = (statusString == "active") ? .active : .inactive
                
                return ChapelCard(
                    attendance: Int(first.attendance),
                    seatPosition: first.seatPosition ?? "정보 없음",
                    floorLevel: UInt32(first.floorLevel),
                    status: status
                )
            } catch {
                print("ChapelCard 조회 실패: \(error.localizedDescription)")
                return ChapelCard(attendance: 0, seatPosition: "정보 없음", floorLevel: 0)
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
            cdChapelCard.floorLevel = Int32(chapelCard.floorLevel)
            cdChapelCard.status = chapelCard.status == .active ? "active" : "inactive"
            
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
            return ChapelCard(attendance: 2, seatPosition: "E-10-4", floorLevel: 1)
        }, getChapelCard: {
            ChapelCard(attendance: 10, seatPosition: "A-3-2", floorLevel: 1)
        }, updateChapelCard: { chapelCard in
            return
        }, deleteChapelCard: {
            return
        }
    )
    
    static let testValue: ChapelClient = previewValue
}
