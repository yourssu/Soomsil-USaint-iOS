//
//  HomeRepository.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/16/24.
//

import Foundation
import KeychainAccess
import CoreData
import Rusaint

public enum ParsingError: Error {
    case error(String)
}

/*
 HomeRepository : Rusaint 기능 중 로컬 저장소를 담당하는 Repository.
 Rusaint로 받아온 데이터를 KeyChain, UserDefaults, Core Data를 이용해서 저장.
 */

class HomeRepository {
    static let shared = HomeRepository(coreDataStack: .shared)

    let coreDataStack: CoreDataStack
    private let keychain = Keychain(service: "com.yourssu.soomsil-ios")

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    func deleteAllData() {
        // Delete - KeyChain, UserDefaults
        deleteUserInformation()

        // Delete - Core Data
        deleteTotalReportCard()
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

        LocalNotificationManager.shared.removeAll()
    }

    func updateUserInformation(id: String, password: String) {
        keychain["saintID"] = id
        keychain["saintPW"] = password
    }

    func getUserLoginInformation() -> [String] {
        let id = keychain["saintID"] ?? ""
        let password = keychain["saintPW"] ?? ""

        return [id, password]
    }

    func updateUserInformation(name: String, major: String, schoolYear: String) {
        keychain["name"] = name
        keychain["major"] = major
        keychain["schoolYear"] = schoolYear
    }

    func updateUserInformation(as user: UserInformation) {
        keychain["saintID"] = user.id
        keychain["saintPW"] = user.password
        keychain["name"] = user.name
        keychain["major"] = user.major
        keychain["schoolYear"] = user.schoolYear
    }

    func updateYearAndSemester(year: String, semester: String) {
        keychain["year"] = year
        keychain["semester"] = semester
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
    }

    // MARK: - TotalReportCard (CoreData)
    private func createTotalReportCard(gpa: Float, earnedCredit: Float, graduateCredit: Float, in context: NSManagedObjectContext) {
        let detail = CDTotalReportCard(context: context)
        detail.gpa = gpa
        detail.earnedCredit = earnedCredit
        detail.graduateCredit = graduateCredit
    }

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

    func updateTotalReportCard(gpa: Float, earnedCredit: Float, graduateCredit: Float) {
        deleteTotalReportCard()
        let context = coreDataStack.taskContext()
        createTotalReportCard(gpa: gpa, earnedCredit: earnedCredit, graduateCredit: graduateCredit, in: context)

        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("update [TotalReportCard] error : \(error)")
            }
        }
    }

    func deleteTotalReportCard() {
        let context = coreDataStack.taskContext()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDTotalReportCard.fetchRequest())
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
