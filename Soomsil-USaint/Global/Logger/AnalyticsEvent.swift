//
//  AnalyticsEvent.swift
//  Soomsil-USaint
//
//  Created by 성현주 on 9/4/25.
//

import Foundation
import Mixpanel

enum AnalyticsEvent {
    
    static func thisSemesterGradeClick(student: StudentInfo, saintId: Int) -> (String, Properties) {
        return (
            "THIS_SEMESTER_GRADE_CHECK_CLICK",
            [
                "department": student.major,
                "schoolId": saintId,
                "schoolYear": student.schoolYear
            ]
        )
    }

    static func allSemesterGradeClick(student: StudentInfo, saintId: Int, chapel: Bool) -> (String, Properties) {
        return (
            "GRADE_CHECK_ALL_SEMESTER_CLICK",
            [
                "department": student.major,
                "schoolId": saintId,
                "schoolYear": student.schoolYear,
                "chapel": chapel
            ]
        )
    }

    static func chapelCheckClick(student: StudentInfo, saintId: Int, chapel: Bool) -> (String, Properties) {
        return (
            "CHAPEL_CHECK_CLICK",
            [
                "department": student.major,
                "schoolId": saintId,
                "schoolYear": student.schoolYear,
                "chapel": chapel
            ]
        )
    }

    static func semesterGradeClick(student: StudentInfo, saintId: Int, semester: String) -> (String, Properties) {
        return (
            "GRADE_CHECK_SEMESTER_\(semester)_CLICK",
            [
                "department": student.major,
                "schoolId": saintId,
                "schoolYear": student.schoolYear,
                "선택한 시기": semester
            ]
        )
    }

    static func latestAcademicAutoLoadClick(student: StudentInfo, saintId: Int) -> (String, Properties) {
        return (
            "LATEST_ACADEMIC_INFO_AUTOLOAD_CLICK",
            [
                "department": student.major,
                "schoolId": saintId,
                "schoolYear": student.schoolYear
            ]
        )
    }

    static func gradeDetailCheckClick(student: StudentInfo, saintId: Int) -> (String, Properties) {
        return (
            "GRADE_DETAIL_CHECK_CLICK",
            [
                "department": student.major,
                "schoolId": saintId,
                "schoolYear": student.schoolYear
            ]
        )
    }

    static func logout(student: StudentInfo, saintId: Int) -> (String, Properties) {
        return (
            "USER_LOGOUT",
            [
                "department": student.major,
                "schoolId": saintId,
                "schoolYear": student.schoolYear
            ]
        )
    }
}
