//
//  AppClipChapelClient.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 11/16/25.
//

import Foundation
import CoreData
import Dependencies
import Rusaint

// MARK: - App Clip 전용 Chapel Client
struct AppClipChapelClient {
    var fetchChapelCard: () async throws -> ChapelCard
//    var getChapelCard: () async throws -> ChapelCard
//    var updateChapelCard: (ChapelCard) async throws -> Void
}

extension AppClipChapelClient: DependencyKey {
    static let liveValue: AppClipChapelClient = AppClipChapelClient(
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
                    throw ChapelError.networkError(error)
                } else {
                    throw ChapelError.networkError(error)
                }
            }
        }/*,
        getChapelCard: {
            let context = CoreDataStack.shared.taskContext()
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
        },
        updateChapelCard: { chapelCard in
            let context = CoreDataStack.shared.taskContext()
            
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
        }*/
    )
    
    static let previewValue: AppClipChapelClient = AppClipChapelClient(
        fetchChapelCard: {
            return ChapelCard(attendance: 2, seatPosition: "E-10-4", floorLevel: 1)
        }/*,
        getChapelCard: {
            return ChapelCard(attendance: 10, seatPosition: "A-3-2", floorLevel: 1)
        },
        updateChapelCard: { _ in
            return
        }*/
    )
    
    static let testValue: AppClipChapelClient = previewValue
}

enum ChapelError: Error {
    case noChapelData        // 채플 정보가 없는 학생
    case networkError(Error) // 네트워크 오류
}

// MARK: - DependencyValues Extension
extension DependencyValues {
    var appClipChapelClient: AppClipChapelClient {
        get { self[AppClipChapelClient.self] }
        set { self[AppClipChapelClient.self] = newValue }
    }
}
