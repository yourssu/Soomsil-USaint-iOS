//
//  HomeViewModel.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/16/24.
//

import SwiftUI

protocol HomeViewModel: ObservableObject {
    var person: StudentInfo? { get set }
    func isLogedIn() -> Bool
    func hasCachedUserInformation() -> Bool
    func syncCachedUserInformation()
    func getCachedUserInformation() -> StudentInfo?
    func hasFeature(_ item: HomeItem) -> Bool
}

final class DefaultSaintHomeViewModel: HomeViewModel {
    @Published var person: StudentInfo?
    private let homeRepository = HomeRepository.shared

    func isLogedIn() -> Bool {
        return self.person != nil
    }
    func hasCachedUserInformation() -> Bool {
        homeRepository.hasCachedUserInformation
    }
    func syncCachedUserInformation() {
        self.person = getCachedUserInformation()
    }
    func getCachedUserInformation() -> StudentInfo? {
        let userInfo = homeRepository.getUserInformation() 
        switch userInfo {
        case let .success(info):
            return StudentInfo(name: info.name, major: info.major, schoolYear: info.schoolYear)
        case .failure:
            break
        }
        return nil
    }
    func hasFeature(_ item: HomeItem) -> Bool {
        switch item {
        case .grade:
            true
        case .chapel:
            true
        case .graduation:
            true
        }
    }
}

final class TestSaintMainHomeViewModel: HomeViewModel {
    @Published var person: StudentInfo?

    func isLogedIn() -> Bool {
        return self.person != nil
    }
    func hasCachedUserInformation() -> Bool {
        true
    }
    func syncCachedUserInformation() {
        self.person = getCachedUserInformation()
    }
    func getCachedUserInformation() -> StudentInfo? {
        StudentInfo(name: "이조은", major: "글로벌미디어학부", schoolYear: "24")
    }
    func hasFeature(_ item: HomeItem) -> Bool {
        switch item {
        case .grade:
            true
        case .chapel:
            true
        case .graduation:
            true
        }
    }
}
