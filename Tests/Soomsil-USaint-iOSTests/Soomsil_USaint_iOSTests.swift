import Testing
@testable import Soomsil_USaint_iOS

@Test func notificationCategoryParsesRemoteValues() async throws {
    #expect(USaintNotificationCategory(remoteValue: "성적") == .gradeAnnouncement)
    #expect(USaintNotificationCategory(remoteValue: "assignment_deadline") == .assignmentDeadline)
    #expect(USaintNotificationCategory(remoteValue: "수강신청") == .courseRegistration)
}

@Test func notificationRouteFallsBackToCategoryDefault() async throws {
    #expect(USaintNotificationRoute(userInfo: [
        NotificationUserInfoKey.category: "채플"
    ]) == .chapel)

    #expect(USaintNotificationRoute(userInfo: [
        NotificationUserInfoKey.category: "성적"
    ]) == .currentSemesterGrades)

    #expect(USaintNotificationRoute(userInfo: [
        NotificationUserInfoKey.category: "과제"
    ]) == .notification)
}

@Test func gradeNotificationRouteOpensCurrentSemesterGrades() async throws {
    #expect(USaintNotificationRoute(remoteValue: "grade_announcement") == .currentSemesterGrades)
    #expect(USaintNotificationRoute(remoteValue: "성적 공개") == .currentSemesterGrades)
}

@Test func notificationCategoriesUseStableFCMTopics() async throws {
    #expect(USaintNotificationCategory.assignmentDeadline.fcmTopic == "usaint_assignment_deadline")
    #expect(USaintNotificationCategory.gradeAnnouncement.fcmTopic == "usaint_grade_announcement")
    #expect(USaintNotificationCategory.chapel.fcmTopic == "usaint_chapel")
}
