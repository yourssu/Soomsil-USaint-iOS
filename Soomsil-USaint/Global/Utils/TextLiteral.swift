//
//  TextLiteral.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import Foundation

enum TextLiteral {
    // MARK: - HomeView

    enum HomeView {
        /// 인사 문구 생성
        /// - Parameter name: 학생 이름
        static func greeting(_ name: String) -> String {
            "안녕하세요, \(name)님"
        }

        /// 알림 요약 문구 생성
        /// - Parameter count: 알림 개수
        static func notificationSummary(count: Int) -> String {
            "이번 주 확인할 알림 \(count)개"
        }
    }

    // MARK: - GPAGraphView

    enum GPAGraphView {
        static let title = "성적 추이"
        static let overallTrendTitle = "전체 학기 추이"
        static let includeSeasonalSemester = "계절학기 포함"
        static let detailButtonTitle = "자세히"

        /// GPA 문구 생성
        /// - Parameter gpa: 평점
        static func gpaValue(_ gpa: Float) -> String {
            let value = Double(gpa)
            let roundedOneDecimal = (value * 10).rounded() / 10

            if abs(value - roundedOneDecimal) < 0.001 {
                return String(format: "%.1f", value)
            }

            return String(format: "%.2f", value)
        }

        /// 축 문구 생성
        /// - Parameter value: 축 값
        static func axisValue(_ value: Double) -> String {
            String(format: "%.1F", value)
        }
    }

    // MARK: - ReportCardView

    enum ReportCardView {
        static let title = "내 성적"
        static let totalSubtitle = "전체"
        static let currentSemesterButtonTitle = "이번 학기 성적보기"
        static let totalGPATitle = "총 평점 평균"
        static let maxGPA = "/ 4.5"
        static let earnedCreditTitle = "취득 학점"
        static let lectureCountTitle = "과목"
        static let totalRankTitle = "전체 석차"

        /// 학점 문구 생성
        /// - Parameter credit: 학점
        static func credit(_ credit: Float) -> String {
            let value = Double(credit)
            let roundedInteger = value.rounded()

            if abs(value - roundedInteger) < 0.001 {
                return String(Int(roundedInteger))
            }

            return String(format: "%.1f", value)
        }

        /// 석차 문구 생성
        /// - Parameter rank: 석차
        static func rank(_ rank: Int) -> String {
            "\(rank)위"
        }

        /// 과목 수 문구 생성
        /// - Parameter count: 과목 수
        static func lectureCount(_ count: Int) -> String {
            "\(count)"
        }
    }

    // MARK: - GradeRowView

    enum GradeRowView {
        static let creditUnit = "학점"
        static let separator = "·"

        /// 학점 문구 생성
        /// - Parameter credit: 학점
        static func credit(_ credit: Double) -> String {
            "\(String(format: "%.1f", credit))\(creditUnit)"
        }

        /// 과목 부가 정보 문구 생성
        static func detailText(
            professorName: String,
            credit: Double
        ) -> String {
            if professorName.isEmpty {
                return Self.credit(credit)
            }

            return "\(professorName) \(separator) \(Self.credit(credit))"
        }
    }

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
