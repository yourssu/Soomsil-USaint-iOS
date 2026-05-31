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

    // MARK: - SettingView

    enum SettingView {
        static let title = "설정"
        static let accountSectionTitle = "계정관리"
        static let logoutButtonTitle = "로그아웃"
        static let notificationSectionTitle = "알림"
        static let gradeNotificationTitle = "성적 알림 받기"
        static let notificationSettingsTitle = "알림 설정"
        static let termsSectionTitle = "약관"
        static let termsOfServiceTitle = "이용약관"
        static let privacyPolicyTitle = "개인정보수집 및 허용"
        static let versionSectionTitle = "버전 정보"

        static func appVersion(_ version: String) -> String {
            "v.\(version)"
        }
    }

    // MARK: - SettingReducer

    enum SettingReducer {
        static let logoutAlertTitle = "정말 로그아웃할까요?"
        static let logoutAlertMessage = "다시 로그인하려면\n학번을 입력해야 해요"
        static let logoutAlertConfirmTitle = "로그아웃"
        static let alertCancelTitle = "취소"
        static let logoutSuccessToast = "로그아웃 완료"
        static let pushAuthorizationDeniedToast = "알림권한 거부"
        static let pushAuthorizationAllowedToast = "알림권한 허용"
        static let pushAuthorizationAlertTitle = "알림 설정"
        static let pushAuthorizationAlertConfirmTitle = "설정"
        static let pushAuthorizationAlertMessage = "알림에 대한 권한 사용을 거부하였습니다. 기능 사용을 원하실 경우 설정 > 앱 > 숨쉴때 유세인트 > 알림 권한 허용을 해주세요."
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
        static let summarySeparator = "·"

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

        /// 요약 항목 문구 생성
        /// - Parameters:
        ///   - title: 제목
        ///   - value: 값
        static func summaryItem(
            title: String,
            value: String
        ) -> String {
            "\(title) \(value)"
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

    // MARK: - ChapelCard

    enum ChapelCard {
        static let inactiveSeatPosition = "이번 학기 채플 수강 없음"
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

    // MARK: - ChapelSeatLocationView

    enum ChapelSeatLocationView {
        static let title = "내 좌석 위치"
        static let stageTitle = "STAGE"
        static let selectedSeatTitle = "이 자리에요"

        static func seatGuide(
            entranceDirection: String,
            row: Int?,
            seatIndexFromEntrance: Int?
        ) -> String {
            guard let row, let seatIndexFromEntrance else {
                return "좌석표에서 파란색으로 표시된 자리가 내 자리예요"
            }

            return "입구에서 \(entranceDirection)으로 입장해 \(ordinal(row)) 줄 \(ordinal(seatIndexFromEntrance)) 자리예요"
        }

        private static func ordinal(_ number: Int) -> String {
            switch number {
            case 1:
                return "첫 번째"
            case 2:
                return "두 번째"
            case 3:
                return "세 번째"
            case 4:
                return "네 번째"
            case 5:
                return "다섯 번째"
            case 6:
                return "여섯 번째"
            case 7:
                return "일곱 번째"
            case 8:
                return "여덟 번째"
            case 9:
                return "아홉 번째"
            case 10:
                return "열 번째"
            default:
                return "\(number)번째"
            }
        }
    }

    // MARK: - ChapelSeatMap

    enum ChapelSeatMap {
        static let leftDirection = "좌측"
        static let rightDirection = "우측"

        static func accessibilityLabel(
            zone: String,
            row: Int,
            column: Int
        ) -> String {
            "\(zone)구역 \(row)번째 줄 \(column)번째 자리"
        }
    }

    // MARK: - ChapelView

    enum ChapelView {
        static let title = "채플"
        static let remainingAttendanceTitle = "이번 학기 남은 출석"
        static let attendanceButtonTitle = "출석 인증하기"
        static let attendanceGuide = "입실 후 좌석 QR을 스캔해주세요"
    }

    // MARK: - MainTabView

    enum MainTabView {
        static let chapelPlaceholder = "채플 화면"
        static let notificationPlaceholder = "알림 화면"
    }

    // MARK: - NotificationView

    enum NotificationView {
        static let title = "알림"
        static let unreadTitle = "읽지 않은 알림"
        static let countUnit = "건"
        static let markAllReadButtonTitle = "모두 읽음"
        static let unreadDescription = "확인할 알림이 많이 쌓였어요"
        static let featuredTitle = "이번 학기 수강신청 안내"
        static let featuredSubtitle = "지금 확인해야 하는 안내가 있어요"
        static let allTabTitle = "전체"
        static let academicTabTitle = "학사"
        static let classTabTitle = "수업"
        static let retentionNotice = "중요 알림은 14일 동안 보관돼요"
    }

    // MARK: - NotificationSettingsView

    enum NotificationSettingsView {
        static let title = "알림 설정"
        static let receiveSectionTitle = "알림 받기"
        static let pushNotificationTitle = "푸시 알림"
        static let pushNotificationSubtitle = "알림으로 소식 받기"
        static let pushNotificationDeniedSubtitle = "iPhone 설정에서 알림을 켜주세요"
        static let typeSectionTitle = "알림 종류"
        static let courseRegistrationTitle = "수강신청"
        static let courseRegistrationSubtitle = "수강신청 일정 알림"
        static let assignmentDeadlineTitle = "과제 마감"
        static let assignmentDeadlineSubtitle = "마감 24시간 전 알림"
        static let gradeAnnouncementTitle = "성적 발표"
        static let gradeAnnouncementSubtitle = "성적 공개 즉시 알림"
        static let chapelTitle = "채플 안내"
        static let chapelSubtitle = "채플 일정 알림"
        static let marketingSectionTitle = "마케팅"
        static let marketingNotificationTitle = "마케팅 알림"
        static let marketingNotificationSubtitle = "이벤트 · 혜택 알림"
        static let debugSectionTitle = "DEBUG"
        static let debugSendTestNotificationTitle = "테스트 알림 보내기"
        static let debugSendTestNotificationSubtitle = "현재 기기에만 2초 뒤 테스트 알림이 예약돼요"
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

    // MARK: - SemesterDetailView

    enum SemesterDetailView {
        static let title = "성적"
        static let loadingTitle = "성적을 불러오는 중입니다"
    }

    // MARK: - CurrentSemesterGradesView

    enum CurrentSemesterGradesView {
        static let totalGPATitle = "총 평점 평균"
        static let earnedCreditTitle = "취득"
        static let lectureCountTitle = "과목"
        static let maxGPA = "/ 4.5"
        static let gpaCalculationDescription = "해당 학점은 현재 등록된 학점을 기준으로 계산되었습니다. \n P/F 과목은 GPA 계산에서 제외됩니다."
        static let emptyTitle = "아직 등록된 성적이 없어요"
        static let emptyDescription = "성적이 등록되면 여기에 표시됩니다"
        static let currentSemesterFallbackTitle = "이번 학기"

        /// 학기 제목 문구 생성
        /// - Parameters:
        ///   - year: 학년도
        ///   - semester: 학기
        static func semesterTitle(
            year: Int,
            semester: String
        ) -> String {
            "\(year.formatted(.number.grouping(.never)))년 \(semester)"
        }

        /// 평균 GPA 문구 생성
        /// - Parameter gpa: 평균 GPA
        static func averageGPA(_ gpa: Double) -> String {
            String(format: "%.2f", gpa)
        }

        /// 취득 학점 문구 생성
        /// - Parameter credit: 취득 학점
        static func credit(_ credit: Double) -> String {
            let roundedInteger = credit.rounded()

            if abs(credit - roundedInteger) < 0.001 {
                return String(Int(roundedInteger))
            }

            return String(format: "%.1f", credit)
        }

        /// 과목 수 문구 생성
        /// - Parameter count: 과목 수
        static func lectureCount(_ count: Int) -> String {
            "\(count)"
        }
    }
}
