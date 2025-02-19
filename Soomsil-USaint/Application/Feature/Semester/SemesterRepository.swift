//
//  ReportCardRepository.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/16/24.
//

import Foundation
import CoreData
import Rusaint
import KeychainAccess


class SemesterRepository {
    static let shared = SemesterRepository(coreDataStack: .shared)
    private let keychain = Keychain(service: "com.yourssu.soomsil-ios")
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - UserInfo
    public func getUserLoginInformation() -> [String] {
        let id = keychain["saintID"] ?? ""
        let password = keychain["saintPW"] ?? ""

        return [id, password]
    }

    // MARK: - TotalReportCard (Core Data)
    public func getTotalReportCard() -> TotalReportCard {
        let context = coreDataStack.taskContext()
        let fetchRequest: NSFetchRequest<CDTotalReportCard> = CDTotalReportCard.fetchRequest()
        do {
            let data = try context.fetch(fetchRequest)
            return data.toTotalReportCard()
        } catch {
            print(error.localizedDescription)
            return TotalReportCard(gpa: 0.00, earnedCredit: 0, graduateCredit: 0)
        }
    }

    // MARK: - SemesterList (Core Data)
    public func getSemesterList() -> [GradeSummary] {
        let context = coreDataStack.taskContext()
        let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()
        do {
            let list = try context.fetch(fetchRequest)
            return list.toGradeSummaryModel()
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    /// - Returns: GradeSummaryModel? 타입으로 리턴됩니다.
    public func getSemester(year: Int, semester: String) -> GradeSummary? {
        let context = coreDataStack.taskContext()
        let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "year == %d", year),
            NSPredicate(format: "semester == %@", semester)
        ])
        
        do {
            if let semesterEntity = try context.fetch(fetchRequest).first {
                return semesterEntity.toGradeSummaryModel()
            } else {
                print("No semester found for Year \(year), Semester \(semester)")
                return nil
            }
        } catch {
            print("Faild to fetch semester: \(error)")
            return nil
        }
    }

    public func updateSemesterList(_ rusaintSemesterList: [GradeSummary]) {
        deleteSemesterList()
        let context = coreDataStack.taskContext()
        for semesterList in rusaintSemesterList {
            createSemester(year: semesterList.year,
                           semester: semesterList.semester,
                           gpa: semesterList.gpa,
                           earnedCredit: semesterList.earnedCredit,
                           semesterRank: semesterList.semesterRank,
                           semesterStudentCount: semesterList.semesterStudentCount,
                           overallRank: semesterList.overallRank,
                           overallStudentCount: semesterList.overallStudentCount,
                           lectures: semesterList.lectures ?? nil,
                           in: context)
        }
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("update report summary error : \(error)")
            }
        }
    }
    
    public func updateLecturesForSemester(year: Int, semester: String, newLectures: [LectureDetail]) {
        let context = coreDataStack.taskContext()
        let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "year == %d", year),
            NSPredicate(format: "semester == %@", semester)
        ])
        
        do {
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
            } else {
                print("해당 학기 찾기 실패: Year \(year), Semester \(semester)")
            }
        } catch {
            print("coredata fetch 실패: \(error)")
        }
    }
    
    func updateGPA(year: Int, semester: String, gpa: Float) {
        let context = coreDataStack.taskContext()
        let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "year == %d", year),
            NSPredicate(format: "semester == %@", semester)
        ])
        
        do {
            if let semesterEntity = try context.fetch(fetchRequest).first {
                semesterEntity.gpa = gpa
                try context.save()
            } else {
                print("No semester found to update GPA for Year \(year), Semester \(semester)")
            }
        } catch {
            print("Failed to update GPA in Core Data: \(error)")
        }
    }
    
    public func addSemester(_ newSemester: GradeSummary) {
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
        
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("add semester error : \(error)")
            }
        }
    }
    
    public func deleteSemesterList() {
        let context = coreDataStack.taskContext()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDSemester.fetchRequest())
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func deleteSemester(year: Int, semester: String) {
        let context = coreDataStack.taskContext()
        let fetchRequest: NSFetchRequest<CDSemester> = CDSemester.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "year == %d", year),
            NSPredicate(format: "semester == %@", semester)
        ])
        
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            try context.save()
            print("Deleted semester: Year \(year), Semester \(semester)")
        } catch {
            print("Failed to delete semester: \(error)")
        }
    }
    
    private func createSemester(
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
}
