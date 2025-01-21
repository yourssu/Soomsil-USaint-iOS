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
    
    var fetchAllSemesterGrades: @Sendable () async throws -> [SemesterGrade]
    var fetchGrades: @Sendable (_ year: Int, _ semester: SemesterType) async throws -> [ClassGrade]
    
    var getAllSemesterGrades: () async throws -> [CDSemester]
    var getGrades: (_ year: Int, _ semester: String) async throws -> CDSemester?
    var updateAllSemesterGrades: (_ rusaintSemesterGrades: [GradeSummary]) async throws -> Void
    var updateGrades: (_ year: Int, _ semester: String, _ newLectures: [LectureDetail]) async throws -> Void
    var updateGPA: (_ year: Int, _ semester: String, _ gpa: Float) async throws -> Void
    var addGrades: (_ newSemester: GradeSummary) async throws -> Void
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
            fetchAllSemesterGrades: {
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
    }()
    
    static let previewValue: GradeClient = GradeClient {
        [
            Rusaint.SemesterGrade(year: 2024,
                               semester: "2 학기",
                               attemptedCredits: 2.0,
                               earnedCredits: 2.0,
                               pfEarnedCredits: 2.0,
                               gradePointsAvarage: 0.0,
                               gradePointsSum: 0.0,
                               arithmeticMean: 0.0,
                               semesterRank: Rusaint.UnsignedIntPair(first: 0, second: 0),
                               generalRank: Rusaint.UnsignedIntPair(first: 12, second: 94),
                               academicProbation: false,
                               consult: false,
                               flunked: false)
        ]
    } fetchGrades: { year, semester in
        [
            Rusaint.ClassGrade(year: "2024", semester: "2 학기", code: "", className: "", gradePoints: 0.0, score: .empty, rank: "", professor: "", detail: nil)
        ]
    } getAllSemesterGrades: {
        [
            CDSemester()
        ]
    } getGrades: { year, semester in
        CDSemester()
    } updateAllSemesterGrades: { rusaintSemesterGrades in
        return
    } updateGrades: { year, semester, newLectures in
        return
    } updateGPA: { year, semester, gpa in
        return
    } addGrades: { newSemester in
        return
    } deleteAllSemesterGrades: {
        return
    } deleteGrades: { year, semester in
        return
    }

    static let testValue: GradeClient = previewValue
}
