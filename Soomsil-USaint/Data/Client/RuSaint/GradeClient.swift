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

    var fetchTotalReportCard:  @Sendable () async throws -> TotalReportCard
    var fetchAllSemesterGrades: @Sendable () async throws -> [SemesterGrade]
    var fetchGrades: @Sendable (_ year: Int, _ semester: SemesterType) async throws -> [ClassGrade]

    var getTotalReportCard: @Sendable () async throws -> TotalReportCard
    var getAllSemesterGrades: () async throws -> [CDSemester]
    var getGrades: (_ year: Int, _ semester: String) async throws -> CDSemester?
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
            fetchTotalReportCard: {
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
                return response
            },
            fetchGrades: { year, semester in
                let session = try await studentClient.createSaintSession()
                let response = try await CourseGradesApplicationBuilder()
                    .build(session: session)
                    .classes(courseType: .bachelor,
                             year: UInt32(year),
                             semester: semester,
                             includeDetails: false)
                return response
            },
            getTotalReportCard: {
                let context = coreDataStack.taskContext()
                let fetchRequest: NSFetchRequest<CDTotalReportCard> = CDTotalReportCard.fetchRequest()

                do {
                    let data = try context.fetch(fetchRequest)
                    return data.toTotalReportCard()
                } catch {
                    print(error.localizedDescription)
                    return TotalReportCard(gpa: 0.00, earnedCredit: 0, graduateCredit: 0)
                }
            },
            getAllSemesterGrades: {
                let context = coreDataStack.taskContext()
                let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()

                let fetchedEntity = try context.fetch(fetchRequest)
                return fetchedEntity
            },
            getGrades: { year, semester in
                let context = coreDataStack.taskContext()
                let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "year == %d", year),
                    NSPredicate(format: "semester == %@", semester)
                ])

                if let fetchedEntity = try? context.fetch(fetchRequest).first {
                    return fetchedEntity
                } else {
                    return nil
                }
            }, updateTotalReportCard: { totalReportCard in
                let context = coreDataStack.taskContext()
                createTotalReportCard(gpa: totalReportCard.gpa, earnedCredit: totalReportCard.earnedCredit, graduateCredit: Float(totalReportCard.graduateCredit), in: context)

                context.performAndWait {
                    do {
                        try context.save()
                    } catch {
                        print("update [TotalReportCard] error : \(error)")
                    }
                }
            },
            updateAllSemesterGrades: { grades in
                let context = coreDataStack.taskContext()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDSemester.fetchRequest())
                try context.execute(deleteRequest)

                for grade in grades {
                    createSemester(year: grade.year,
                                   semester: grade.semester,
                                   gpa: grade.gpa,
                                   earnedCredit: grade.earnedCredit,
                                   semesterRank: grade.semesterRank,
                                   semesterStudentCount: grade.semesterStudentCount,
                                   overallRank: grade.overallRank,
                                   overallStudentCount: grade.overallStudentCount,
                                   lectures: grade.lectures ?? nil,
                                   in: context)
                }
                try context.save()
            },
            updateGrades: { year, semester, newLectures in
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
            },
            updateGPA: { year, semester, gpa in
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
            },
            addGrades: { newSemester in
                let context = coreDataStack.taskContext()

                createSemester(year: newSemester.year,
                               semester: newSemester.semester,
                               gpa: newSemester.gpa,
                               earnedCredit: newSemester.earnedCredit,
                               semesterRank: newSemester.semesterRank,
                               semesterStudentCount: newSemester.semesterStudentCount,
                               overallRank: newSemester.overallRank,
                               overallStudentCount: newSemester.overallStudentCount,
                               lectures: newSemester.lectures ?? nil,
                               in: context)

                try context.save()
            },
            deleteTotalReportCard: {
                let context = coreDataStack.taskContext()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDTotalReportCard.fetchRequest())

                try context.execute(deleteRequest)
                try context.save()
            },
            deleteAllSemesterGrades: {
                let context = coreDataStack.taskContext()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDSemester.fetchRequest())

                try context.execute(deleteRequest)
                try context.save()
            },
            deleteGrades: { year,semester in
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

        func createSemester(
            year: Int,
            semester: String,
            gpa: Float,
            earnedCredit: Float,
            semesterRank: Int,
            semesterStudentCount: Int,
            overallRank: Int,
            overallStudentCount: Int,
            lectures: [LectureDetail]?,
            in context: NSManagedObjectContext
        ) {
            let semesterEntity = CDSemester(context: context)
            semesterEntity.year = Int16(year)
            semesterEntity.semester = semester
            semesterEntity.gpa = gpa
            semesterEntity.earnedCredit = earnedCredit
            semesterEntity.semesterRank = Int16(semesterRank)
            semesterEntity.semesterStudentCount = Int16(semesterStudentCount)
            semesterEntity.overallRank = Int16(overallRank)
            semesterEntity.overallStudentCount = Int16(overallStudentCount)

            let lectureEntities = lectures?.compactMap { lecture -> CDLecture? in
                let cdLecture = CDLecture(context: context)
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

        func createTotalReportCard(
            gpa: Float,
            earnedCredit: Float,
            graduateCredit: Float,
            in context: NSManagedObjectContext
        ) {
            let detail = CDTotalReportCard(context: context)
            detail.gpa = gpa
            detail.earnedCredit = earnedCredit
            detail.graduateCredit = graduateCredit
        }
    }()

    static let previewValue: GradeClient = Self(
        fetchTotalReportCard: {
            return TotalReportCard(gpa: 4.11, earnedCredit: 112, graduateCredit: 188)
        }, fetchAllSemesterGrades:  {
            [
                SemesterGrade(
                    year: 2024,
                    semester: "",
                    attemptedCredits: 22.0,
                    earnedCredits: 4.3,
                    pfEarnedCredits: 3.0,
                    gradePointsAvarage: 3.0,
                    gradePointsSum: 2.0,
                    arithmeticMean: 2.0,
                    semesterRank: U32Pair(first: 57, second: 100),
                    generalRank: U32Pair(first: 38, second: 200),
                    academicProbation: false,
                    consult: false,
                    flunked: false
                )
            ]
        }, fetchGrades: { year, semester in
            [
                Rusaint.ClassGrade(year: "2024", semester: "2 학기", code: "", className: "", gradePoints: 0.0, score: .empty, rank: "", professor: "", detail: nil)
            ]
        }, getTotalReportCard: {
            TotalReportCard(gpa: 4.34, earnedCredit: 108, graduateCredit: 133)
        }, getAllSemesterGrades: {
            [
                CDSemester()
            ]
        }, getGrades: { year, semester in
            CDSemester()
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
