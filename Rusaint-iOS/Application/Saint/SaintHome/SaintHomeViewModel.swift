//
//  SaintHomeViewModel.swift
//  Soomsil
//
//  Created by 오동규 on 2023/09/06.
//  Copyright © 2023 Yourssu. All rights reserved.
//

import SwiftUI

protocol SaintHomeViewModel: ObservableObject {
    var person: SaintPersonalInfo? { get set }
    func isLogedIn() -> Bool
    func hasCachedUserInformation() -> Bool
    func syncCachedUserInformation()
    func getCachedUserInformation() -> SaintPersonalInfo?
    func hasFeature(_ item: SaintItem) -> Bool
}

final class DefaultSaintHomeViewModel: SaintHomeViewModel {
    @Published var person: SaintPersonalInfo?
    private let saintRepository = SaintRepository.shared

    func isLogedIn() -> Bool {
        return self.person != nil
    }
    func hasCachedUserInformation() -> Bool {
        saintRepository.hasCachedUserInformation
    }
    func syncCachedUserInformation() {
        self.person = getCachedUserInformation()
    }
    func getCachedUserInformation() -> SaintPersonalInfo? {
        let userInfo = saintRepository.getUserInformation()
        switch userInfo {
        case let .success(info):
            return SaintPersonalInfo(name: info.name, major: info.major, schoolYear: info.schoolYear)
        case .failure:
            break
        }
        return nil
    }
    func hasFeature(_ item: SaintItem) -> Bool {
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

final class AppClipSaintHomeViewModel: SaintHomeViewModel {
    @Published var person: SaintPersonalInfo?
    private let saintRepository = SaintRepository.shared

    func isLogedIn() -> Bool {
        return self.person != nil
    }
    func hasCachedUserInformation() -> Bool {
        saintRepository.hasCachedUserInformation
    }
    func syncCachedUserInformation() {
        self.person = getCachedUserInformation()
    }
    func getCachedUserInformation() -> SaintPersonalInfo? {
        let userInfo = saintRepository.getUserInformation()
        switch userInfo {
        case let .success(info):
            return SaintPersonalInfo(name: info.name, major: info.major, schoolYear: info.schoolYear)
        case .failure:
            break
        }
        return nil
    }
    func hasFeature(_ item: SaintItem) -> Bool {
        switch item {
        case .grade:
            true
        case .chapel:
            false
        case .graduation:
            false
        }
    }
}

final class TestSaintMainHomeViewModel: SaintHomeViewModel {
    @Published var person: SaintPersonalInfo?

    func isLogedIn() -> Bool {
        return self.person != nil
    }
    func hasCachedUserInformation() -> Bool {
        true
    }
    func syncCachedUserInformation() {
        self.person = getCachedUserInformation()
    }
    func getCachedUserInformation() -> SaintPersonalInfo? {
        SaintPersonalInfo(name: "오깨비", major: "언론홍보학과", schoolYear: "2학년")
    }
    func hasFeature(_ item: SaintItem) -> Bool {
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
