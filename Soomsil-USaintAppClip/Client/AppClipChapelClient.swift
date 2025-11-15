//
//  AppClipChapelClient.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 11/16/25.
//

import Foundation
import Dependencies
import Rusaint

// MARK: - 앱클립 전용 Chapel Client (fetch만)
struct AppClipChapelClient {
    var fetchChapelCard: (USaintSession) async throws -> ChapelCard
}

extension AppClipChapelClient: DependencyKey {
    static let liveValue: AppClipChapelClient = AppClipChapelClient(
        fetchChapelCard: { session in
            do {
                // ChapelApplication 생성
                let chapelApp = try await ChapelApplicationBuilder().build(session: session)
                
                // 현재 학기 정보 가져오기
                let currentYear = UInt32(Calendar.current.component(.year, from: Date()))
                let currentMonth = UInt32(Calendar.current.component(.month, from: Date()))
                let semester: SemesterType = currentMonth <= 6 ? .one : .two
                
                // 채플 정보 가져오기
                let chapelInfo = try await chapelApp.information(year: currentYear, semester: semester)
                
                // ChapelCard 생성
                let attendanceCount = chapelInfo.attendances.filter { $0.attendance == "출석" }.count
                let seatPosition = chapelInfo.generalInformation.seatNumber
                let floorLevel = chapelInfo.generalInformation.floorLevel
                
                return ChapelCard(attendance: attendanceCount, seatPosition: seatPosition, floorLevel: floorLevel)
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
        }
    )
    
    static let previewValue: AppClipChapelClient = AppClipChapelClient(
        fetchChapelCard: { _ in
            return ChapelCard(attendance: 2, seatPosition: "E-10-4", floorLevel: 1)
        }
    )
    
    static let testValue: AppClipChapelClient = previewValue
}

enum ChapelError: Error {
    case noChapelData        // 채플 정보가 없는 학생
    case networkError(Error) // 네트워크 오류
}

extension DependencyValues {
    var appClipChapelClient: AppClipChapelClient {
        get { self[AppClipChapelClient.self] }
        set { self[AppClipChapelClient.self] = newValue }
    }
}
