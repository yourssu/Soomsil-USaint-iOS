//
//  CDTotalReportCard+.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 2/3/25.
//

import CoreData

extension NSManagedObjectContext {
    func createTotalReportCard(gpa: Float, earnedCredit: Float, graduateCredit: Float) {
        let detail = CDTotalReportCard(context: self)
        detail.gpa = gpa
        detail.earnedCredit = earnedCredit
        detail.graduateCredit = graduateCredit
    }

    func createSemester(
        year: Int,
        semester: String,
        gpa: Float,
        earnedCredit: Float,
        semesterRank: Int,
        semesterStudentCount: Int,
        overallRank: Int,
        overallStudentCount: Int,
        lectures: [LectureDetail]?
    ) {
        let semesterEntity = CDSemester(context: self)
        semesterEntity.year = Int16(year)
        semesterEntity.semester = semester
        semesterEntity.gpa = gpa
        semesterEntity.earnedCredit = earnedCredit
        semesterEntity.semesterRank = Int16(semesterRank)
        semesterEntity.semesterStudentCount = Int16(semesterStudentCount)
        semesterEntity.overallRank = Int16(overallRank)
        semesterEntity.overallStudentCount = Int16(overallStudentCount)

        let lectureEntities = lectures?.compactMap { lecture -> CDLecture? in
            let cdLecture = CDLecture(context: self)
            cdLecture.code = lecture.code
            cdLecture.title = lecture.title
            cdLecture.credit = Float(lecture.credit)
            cdLecture.score = lecture.score
            cdLecture.grade = lecture.grade.rawValue
            cdLecture.professorName = lecture.professorName
            return cdLecture
        }
        lectureEntities?.forEach { semesterEntity.addToLectures($0) }
    }
}
