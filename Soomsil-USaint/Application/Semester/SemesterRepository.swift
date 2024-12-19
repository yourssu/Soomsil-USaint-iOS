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
    // FIXME: - user session 위해 필요
//    private let keychain = Keychain(service: "com.yourssu.soomsil-ios")
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - UserInfo
    func getUserLoginInformation() -> [String] {
        let id = keychain["saintID"] ?? ""
        let password = keychain["saintPW"] ?? ""

        return [id, password]
    }

    // MARK: - TotalReportCard (Core Data)
    func getTotalReportCard() -> TotalReportCardModel {
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
    
    private func createSemester(
        year: Int,
        semester: String,
        gpa: Float,
        earnedCredit: Float,
        semesterRank: Int,
        semesterStudentCount: Int,
        overallRank: Int,
        overallStudentCount: Int,
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
    }
}

