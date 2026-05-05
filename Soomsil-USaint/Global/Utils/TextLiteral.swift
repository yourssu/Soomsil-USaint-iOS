//
//  TextLiteral.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import Foundation

enum TextLiteral {
    // MARK: - ChapelAttendanceInfoView

    enum ChapelAttendanceInfoView {
        static let semesterTitle = "이번 학기 출석"
        static let attendedTitle = "채플 출석"
        static let completedTitle = "채플 수료 완료!"

        /// 필수 출석 횟수 문구 생성
        static func requiredCount(_ count: Int) -> String {
            "/ \(count)회"
        }

        /// 출석 요약 문구 생성
        static func attendanceSummary(
            attendanceCount: Int,
            requiredAttendanceCount: Int
        ) -> String {
            "\(attendanceCount)/\(requiredAttendanceCount)회 출석"
        }

        /// 출석 퍼센트 문구 생성
        static func attendancePercent(_ percent: Int) -> String {
            "\(percent)%"
        }
    }

    // MARK: - ChapelSeatInfoView

    enum ChapelSeatInfoView {
        static let title = "내 자리"
        static let locationButtonTitle = "좌석 위치 보기"
        static let defaultZone = "A"
        static let zoneSeparator = "-"

        /// 좌석 설명 문구 생성
        static func seatDescription(
            floorLevel: UInt32,
            seatZone: String
        ) -> String {
            "\(floorLevel)층 앞자리 · \(seatZone)구역"
        }
    }

    // MARK: - MainTabView

    enum MainTabView {
        static let chapelPlaceholder = "채플 화면"
        static let notificationPlaceholder = "알림 화면"
    }

    // MARK: - StudentInfoView

    enum StudentInfoView {
        static let enrollmentStatus = "재학"

        /// 학번 문구 생성
        static func studentID(_ studentID: String) -> String {
            "학번 \(studentID)"
        }

        /// 학생 부가 정보 문구 생성
        static func subtitle(
            major: String,
            schoolYear: String
        ) -> String {
            "\(major) · \(schoolYear) · \(enrollmentStatus)"
        }
    }
}
