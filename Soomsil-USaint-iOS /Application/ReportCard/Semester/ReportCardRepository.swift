//
//  ReportCardRepository.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/16/24.
//

import Foundation
import CoreData
import Rusaint


/**
 Rusaint에서 반환하는 오류
 
 현재 오류에 대한 세부정보를 연관 값으로 받지 않고 에러 타입만 정의해둔 상태
 */
public enum RusaintError: Error {
    case webDynproError
    case invalidClientError
    case ssoLoginError
    case applicationError
}

class ReportCardRepository {
    static let shared = ReportCardRepository(coreDataStack: .shared)
    
    let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - SemesterList (Core Data)
//    public func getSemesterList
}

