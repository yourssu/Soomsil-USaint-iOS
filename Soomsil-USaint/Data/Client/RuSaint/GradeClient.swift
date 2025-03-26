//
//  GradeClient.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 1/9/25.
//
import CoreData

import ComposableArchitecture
import Rusaint

@DependencyClient
struct GradeClient {
    static let coreDataStack: CoreDataStack = .shared

    var currentYearAndSemester: @Sendable () async throws -> (year: Int, semester: SemesterType)?

    var fetchTotalReportCard:  @Sendable () async throws -> TotalReportCard
    var fetchAllSemesterGrades: @Sendable () async throws -> [GradeSummary]
    var fetchGrades: @Sendable (_ year: Int, _ semester: SemesterType) async throws -> [ClassGrade]

    var getTotalReportCard: @Sendable () async throws -> TotalReportCard
    var getAllSemesterGrades: () async throws -> [GradeSummary]
    var getGrades: (_ year: Int, _ semester: String) async throws -> GradeSummary?
    var updateTotalReportCard: @Sendable (_ totalReportCard: TotalReportCard) async throws -> Void
    var updateAllSemesterGrades: (_ rusaintSemesterGrades: [GradeSummary]) async throws -> Void
    var updateGrades: (_ year: Int, _ semester: String, _ newLectures: [LectureDetail]) async throws -> Void
    var updateGPA: (_ year: Int, _ semester: String, _ gpa: Float) async throws -> Void
    var addGrades: (_ newSemester: GradeSummary) async throws -> Void
    var deleteTotalReportCard: @Sendable () async throws -> Void
    var deleteAllSemesterGrades: () async throws -> Void
    var deleteGrades: (_ year: Int, _ semester: String) async throws -> Void
}

extension DependencyValues {
    var gradeClient: GradeClient {
        get { self[GradeClient.self] }
        set { self[GradeClient.self] = newValue }
    }
}

extension GradeClient: DependencyKey {
    static var liveValue: GradeClient = {
        @Dependency(\.studentClient) var studentClient: StudentClient

        return GradeClient(
            currentYearAndSemester: {
                /// 현재 가장 최근 학기 정보를 알려줍니다.
                /// (ex) 25년 1월 13일은 (year: 24, semester: "겨울 학기") 로 리턴됩니다.
                /// - Returns: year는 Int로, semester은 "1 학기", "여름학기", "2 학기", "겨울학기" 중 하나로 리턴됩니다.

                let date = Date()
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: date)

                guard let year = components.year,
                      let month = components.month,
                      let day = components.day else {
                    return nil
                }

                switch (month: month, day: day) {
                case DateRange(start: (month: 6, day: 8), end: (month: 7, day: 7)):
                    return (year: year, semester: .one)
                case DateRange(start: (month: 7, day: 11), end: (month: 7, day: 25)):
                    return (year: year, semester: .summer)
                case DateRange(start: (month: 12, day: 8), end: (month: 12, day: 31)):
                    return (year: year, semester: .two)
                case DateRange(start: (month: 1, day: 1), end: (month: 1, day: 7)):
                    return (year: year - 1, semester: .two)
                case DateRange(start: (month: 1, day: 11), end: (month: 1, day: 26)):
                    return (year: year - 1, semester: .winter)
                default:
                    return nil
                }
            }, fetchTotalReportCard: {
                let session = try await studentClient.createSaintSession()
                let courseGrades = try await CourseGradesApplicationBuilder().build(session: session).certificatedSummary(courseType: .bachelor)
                let graduationRequirement = try await GraduationRequirementsApplicationBuilder().build(session: session).requirements()
                let requirements = graduationRequirement.requirements.filter { $0.value.name.hasPrefix("학부-졸업학점") }
                    .compactMap { $0.value.requirement ?? 0}
                guard let graduateCredit = requirements.first else {
                    throw RusaintError.invalidClientError
                }
                return TotalReportCard(
                    gpa: courseGrades.gradePointsAvarage,
                    earnedCredit: courseGrades.earnedCredits,
                    graduateCredit: Float(graduateCredit)
                )
            }, fetchAllSemesterGrades: {
                let session = try await studentClient.createSaintSession()
                let response = try await CourseGradesApplicationBuilder()
                    .build(session: session)
                    .semesters(courseType: CourseType.bachelor)
                return response.toGradeSummaryModels()
            }, fetchGrades: { year, semester in
                let session = try await studentClient.createSaintSession()
                let response = try await CourseGradesApplicationBuilder()
                    .build(session: session)
                    .classes(courseType: .bachelor,
                             year: UInt32(year),
                             semester: semester,
                             includeDetails: false)
                return response
            }, getTotalReportCard: {
                let context = coreDataStack.taskContext()
                let fetchRequest: NSFetchRequest<CDTotalReportCard> = CDTotalReportCard.fetchRequest()

                do {
                    let data = try context.fetch(fetchRequest)
                    return data.toTotalReportCard()
                } catch {
                    print(error.localizedDescription)
                    return TotalReportCard(gpa: 0.00, earnedCredit: 0, graduateCredit: 0)
                }
            }, getAllSemesterGrades: {
                let context = coreDataStack.taskContext()
                let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()

                let fetchedEntity = try context.fetch(fetchRequest)
                return fetchedEntity.toGradeSummaryModel()
            }, getGrades: { year, semester in
                let context = coreDataStack.taskContext()
                let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "year == %d", year),
                    NSPredicate(format: "semester == %@", semester)
                ])

                if let fetchedEntity = try? context.fetch(fetchRequest).first {
                    return fetchedEntity.toGradeSummaryModel()
                } else {
                    return nil
                }
            }, updateTotalReportCard: { totalReportCard in
                let context = coreDataStack.taskContext()
                context.createTotalReportCard(gpa: totalReportCard.gpa, earnedCredit: totalReportCard.earnedCredit, graduateCredit: Float(totalReportCard.graduateCredit))

                context.performAndWait {
                    do {
                        try context.save()
                    } catch {
                        print("update [TotalReportCard] error : \(error)")
                    }
                }
            }, updateAllSemesterGrades: { grades in
                let context = coreDataStack.taskContext()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDSemester.fetchRequest())
                try context.execute(deleteRequest)

                for grade in grades {
                    context.createSemester(year: grade.year,
                                   semester: grade.semester,
                                   gpa: grade.gpa,
                                   earnedCredit: grade.earnedCredit,
                                   semesterRank: grade.semesterRank,
                                   semesterStudentCount: grade.semesterStudentCount,
                                   overallRank: grade.overallRank,
                                   overallStudentCount: grade.overallStudentCount,
                                   lectures: grade.lectures ?? nil)
                }
                try context.save()
            }, updateGrades: { year, semester, newLectures in
                let context = coreDataStack.taskContext()
                let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()

                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "year == %d", year),
                    NSPredicate(format: "semester == %@", semester)
                ])

                if let semesterEntity = try context.fetch(fetchRequest).first {
                    semesterEntity.removeFromLectures(semesterEntity.lectures ?? [])

                    let newLectureEntities = newLectures.map { lecture in
                        let cdLecture = CDLecture(context: context)
                        cdLecture.code = lecture.code
                        cdLecture.title = lecture.title
                        cdLecture.credit = Float(lecture.credit)
                        cdLecture.score = lecture.score
                        cdLecture.grade = lecture.grade.rawValue
                        cdLecture.professorName = lecture.professorName
                        return cdLecture
                    }

                    newLectureEntities.forEach { semesterEntity.addToLectures($0) }
                    context.performAndWait {
                        do {
                            try context.save()
                        } catch {
                            print("lectures 업데이트 실패: \(error.localizedDescription)")
                        }
                    }
                }
            }, updateGPA: { year, semester, gpa in
                let context = coreDataStack.taskContext()
                let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "year == %d", year),
                    NSPredicate(format: "semester == %@", semester)
                ])

                if let fetchedEntity = try context.fetch(fetchRequest).first {
                    fetchedEntity.gpa = gpa
                    try context.save()
                }
            }, addGrades: { newSemester in
                let context = coreDataStack.taskContext()


                context.createSemester(year: newSemester.year,
                               semester: newSemester.semester,
                               gpa: newSemester.gpa,
                               earnedCredit: newSemester.earnedCredit,
                               semesterRank: newSemester.semesterRank,
                               semesterStudentCount: newSemester.semesterStudentCount,
                               overallRank: newSemester.overallRank,
                               overallStudentCount: newSemester.overallStudentCount,
                               lectures: newSemester.lectures ?? nil)

                try context.save()
            }, deleteTotalReportCard: {
                let context = coreDataStack.taskContext()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDTotalReportCard.fetchRequest())

                try context.execute(deleteRequest)
                try context.save()
            }, deleteAllSemesterGrades: {
                let context = coreDataStack.taskContext()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDSemester.fetchRequest())

                try context.execute(deleteRequest)
                try context.save()
            }, deleteGrades: { year,semester in
                let context = coreDataStack.taskContext()
                let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "year == %d", year),
                    NSPredicate(format: "semester == %@", semester)
                ])

                let fetchedEntity = try context.fetch(fetchRequest)
                for entity in fetchedEntity {
                    context.delete(entity)
                }
                try context.save()
            }
        )
    }()

    static let previewValue: GradeClient = Self(
        currentYearAndSemester: {
            return (year: 2025, semester: SemesterType.one)
        }, fetchTotalReportCard: {
            return TotalReportCard(gpa: 4.11, earnedCredit: 112, graduateCredit: 188)
        }, fetchAllSemesterGrades:  {
            [
                GradeSummary(year: 2024, semester: "2 학기", gpa: 4.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "fetchAll", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")]),
                 GradeSummary(year: 2024, semester: "1 학기", gpa: 4.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "fetchAll", credit: 3.0, score: "4.0", grade: .aZero, professorName: "이조은")])
            ]
        }, fetchGrades: { year, semester in
            [
                Rusaint.ClassGrade(year: "2024", semester: "2 학기", code: "", className: "", gradePoints: 0.0, score: .empty, rank: "", professor: "", detail: nil)
            ]
        }, getTotalReportCard: {
            TotalReportCard(gpa: 4.34, earnedCredit: 133, graduateCredit: 133)
        }, getAllSemesterGrades: {
            [
                GradeSummary(year: 2024, semester: "여름 학기", gpa: 4.0, earnedCredit: 18, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "getAll", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")]),
                GradeSummary(year: 2024, semester: "1 학기", gpa: 4.2, earnedCredit: 17, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "getAll", credit: 3.0, score: "4.2", grade: .aZero, professorName: "이조은")]),
                GradeSummary(year: 2023, semester: "2 학기", gpa: 4.5, earnedCredit: 16, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "getAll", credit: 3.0, score: "4.5", grade: .aZero, professorName: "이조은")]),
                GradeSummary(year: 2023, semester: "1 학기", gpa: 4.2, earnedCredit: 18, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "getAll", credit: 3.0, score: "4.2", grade: .aZero, professorName: "이조은")])
            ]
        }, getGrades: { year, semester in
            GradeSummary(year: 2024, semester: "2 학기", gpa: 4.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")])
        }, updateTotalReportCard: { totalReportCard in
            return
        }, updateAllSemesterGrades: { rusaintSemesterGrades in
            return
        }, updateGrades: { year, semester, newLectures in
            return
        }, updateGPA: { year, semester, gpa in
            return
        }, addGrades: { newSemester in
            return
        }, deleteTotalReportCard: {
            return
        }, deleteAllSemesterGrades: {
            return
        }, deleteGrades: { year, semester in
            return
        }
    )

    static let testValue: GradeClient = previewValue
}
