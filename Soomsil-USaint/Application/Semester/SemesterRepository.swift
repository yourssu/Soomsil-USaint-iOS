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
    public func getTotalReportCard() -> TotalReportCardModel {
        let context = coreDataStack.taskContext()
        let fetchRequest: NSFetchRequest<CDTotalReportCard> = CDTotalReportCard.fetchRequest()
        do {
            let data = try context.fetch(fetchRequest)
            return data.toTotalReportCardModel()
        } catch {
            print(error.localizedDescription)
            return TotalReportCardModel(gpa: 0.00, earnedCredit: 0, graduateCredit: 0)
        }
    }

    // MARK: - SemesterList (Core Data)
    public func getSemesterList() -> [GradeSummaryModel] {
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
    
    // MARK: get 이번학기 코어데이터 
    
    public func updateSemesterList(_ rusaintSemesterList: [GradeSummaryModel]) {
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
                           lectures: semesterList.lectures,
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
    
    public func addSemester(_ newSemester: GradeSummaryModel) {
        let context = coreDataStack.taskContext()
        
        createSemester(year: newSemester.year,
                       semester: newSemester.semester,
                       gpa: newSemester.gpa,
                       earnedCredit: newSemester.earnedCredit,
                       semesterRank: newSemester.semesterRank,
                       semesterStudentCount: newSemester.semesterStudentCount,
                       overallRank: newSemester.overallRank,
                       overallStudentCount: newSemester.overallStudentCount,
                       lectures: newSemester.lectures,
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
        lectures: [LectureDetailModel],
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
        
        for lecture in lectures {
            let cdLecture = CDLecture(context: context)
            cdLecture.code = lecture.code
            cdLecture.title = lecture.title
            cdLecture.credit = Float(lecture.credit)
            cdLecture.score = lecture.score
            cdLecture.grade = "\(lecture.grade)"
            cdLecture.professorName = lecture.professorName
            semesterEntity.addToLectures(cdLecture)
        }
    }
}
