//
//  SaintRepository.swift
//  Soomsil
//
//  Created by 정종인 on 1/1/24.
//  Copyright © 2024 Yourssu. All rights reserved.
//

import Foundation
import KeychainAccess
import CoreData
import SaintNexus

public enum ParsingError: Error {
    case error(String)
}

/*
 SaintRepository : Saint-Nexus 기능 중 로컬 저장소를 담당하는 Repository.

 Saint Nexus로 받아온 데이터를 KeyChain, UserDefaults, Core Data를 이용해서 저장.
 저장할 때는 SN~~ 접두사가 붙은 모델을 CD~~ 접두사가 붙은 모델로 바꿈.
 데이터를 가져올 때는 접두사가 붙지 않은 모델로 바꿈.
 */
class SaintRepository {
    static let shared = SaintRepository(coreDataStack: .shared)

    let coreDataStack: CoreDataStack
    private let keychain = Keychain(service: "com.yourssu.soomsil-ios")

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    func deleteAllData() {
        deleteUserInformation()
        deleteAllReportDetails()
        deleteReportSummaries()
    }

    // MARK: - UserInformation (KeyChain, UserDefaults)
    var hasCachedUserInformation: Bool {
        let hasID = (keychain["saintID"] != nil)
        let hasPassword = (keychain["saintPW"] != nil)

        return hasID && hasPassword
    }

    func deleteUserInformation() {
        try? keychain.remove("saintID")
        try? keychain.remove("saintPW")
        try? keychain.remove("name")
        try? keychain.remove("major")
        try? keychain.remove("schoolYear")
        try? keychain.remove("year")
        try? keychain.remove("semester")

        SaintNexus.shared.userData.removeAll()
    }

    func updateUserInformation(id: String, password: String) {
        keychain["saintID"] = id
        keychain["saintPW"] = password

        SaintNexus.shared.userData["id"] = id
        SaintNexus.shared.userData["pw"] = password
    }

    func updateUserInformation(name: String, major: String, schoolYear: String) {
        keychain["name"] = name
        keychain["major"] = major
        keychain["schoolYear"] = schoolYear

        SaintNexus.shared.userData["name"] = name
        SaintNexus.shared.userData["major"] = major
        SaintNexus.shared.userData["schoolYear"] = schoolYear
    }

    func updateUserInformation(as user: UserInformation) {
        keychain["saintID"] = user.id
        keychain["saintPW"] = user.password
        keychain["name"] = user.name
        keychain["major"] = user.major
        keychain["schoolYear"] = user.schoolYear

        SaintNexus.shared.userData["id"] = user.id
        SaintNexus.shared.userData["pw"] = user.password
        SaintNexus.shared.userData["name"] = user.name
        SaintNexus.shared.userData["major"] = user.major
        SaintNexus.shared.userData["schoolYear"] = user.schoolYear
    }

    func updateYearAndSemester(year: String, semester: String) {
        keychain["year"] = year
        keychain["semester"] = semester

        SaintNexus.shared.userData["year"] = year
        SaintNexus.shared.userData["semester"] = semester
    }

    func getUserInformation() -> Result<UserInformation, ParsingError> {
        guard let id = keychain["saintID"],
              let password = keychain["saintPW"],
              let name = keychain["name"],
              let major = keychain["major"],
              let schoolYear = keychain["schoolYear"]
        else { return .failure(.error("저장된 정보가 없습니다.")) }

        return .success(UserInformation(id: id, password: password, name: name, major: major, schoolYear: schoolYear))
    }

    func setYearAndSemester(_ year: String, _ semester: String) {
        keychain["year"] = year
        keychain["semester"] = semester

        SaintNexus.shared.userData["year"] = year
        SaintNexus.shared.userData["semester"] = semester
    }

// MARK: - ReportSummary (Core Data)
    func getReportSummaryList() -> [ReportSummaryModel] {
        let context = coreDataStack.taskContext()
        let fetchRequest: NSFetchRequest<CDReportSummary> = CDReportSummary.fetchRequest()
        do {
            let list = try context.fetch(fetchRequest)
            return list.toReportSummaryModel()
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func updateReportSummary(_ snReportList: SNReportList) {
        deleteReportSummaries()
        let dicts = snReportList.toDictionaries()
        let context = coreDataStack.taskContext()
        for dict in dicts {
            createReportSummary(
                year: dict["학년도"] ?? "",
                semester: dict["학기"] ?? "",
                credit: Double(dict["취득학점"] ?? "0") ?? 0,
                pfCredit: Double(dict["P/F학점"] ?? "0") ?? 0,
                semesterGPA: Double(dict["평점평균"] ?? "0") ?? 0,
                semesterRank: dict["학기별석차"] ?? "",
                totalRank: dict["전체석차"] ?? "",
                in: context
            )
        }
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("update report summary error : \(error)")
            }
        }
    }

    func deleteReportSummaries() {
        let context = coreDataStack.taskContext()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDReportSummary.fetchRequest())
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    // swiftlint:disable function_parameter_count
    private func createReportSummary(
        year: String?,
        semester: String?,
        credit: Double,
        pfCredit: Double,
        semesterGPA: Double,
        semesterRank: String?,
        totalRank: String?,
        in context: NSManagedObjectContext
    ) {
        let summary = CDReportSummary(context: context)
        summary.year = year
        summary.semester = semester
        summary.credit = credit
        summary.pfCredit = pfCredit
        summary.semesterGPA = semesterGPA
        summary.semesterRank = semesterRank
        summary.totalRank = totalRank
    }
    // swiftlint:enable function_parameter_count

// MARK: - ReportDetail (Core Data)
    func getReportDetail(_ year: String, _ semester: String) -> ReportDetailModel? {
        let context = coreDataStack.taskContext()
        let fetchRequest: NSFetchRequest<CDReportDetail> = CDReportDetail.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(year == %@) AND (semester == %@)", year, semester)
        do {
            return try context.fetch(fetchRequest).first?.toReportDetailModel()
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func updateReportDetail(_ snSemesterReportCard: SNSemesterReportCard) {
        deleteReportDetails(snSemesterReportCard.year, snSemesterReportCard.semester)
        let context = coreDataStack.taskContext()
        createReportDetail(
            year: snSemesterReportCard.year,
            semester: snSemesterReportCard.semester,
            lectures: snSemesterReportCard.lectures,
            in: context
        )
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("update report detail list error : \(error)")
            }
        }
    }

    func deleteReportDetails(_ year: String, _ semester: String) {
        let context = coreDataStack.taskContext()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDReportDetail.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(year == %@) AND (semester == %@)", year, semester)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    func deleteAllReportDetails() {
        let context = coreDataStack.taskContext()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDReportDetail.fetchRequest())
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func createReportDetail(
        year: String?,
        semester: String?,
        lectures: [SNLectureReportCard],
        in context: NSManagedObjectContext
    ) {
        let detail = CDReportDetail(context: context)
        detail.year = year
        detail.semester = semester
        for lecture in lectures {
            let cdLecture = CDLecture(context: context)
            cdLecture.code = lecture.code
            cdLecture.title = lecture.title
            cdLecture.credit = lecture.credit
            cdLecture.score = lecture.score
            cdLecture.grade = lecture.grade
            cdLecture.professorName = lecture.professorName
            detail.addToLectures(cdLecture)
        }
    }
}
