//
//  CoreDataStack.swift
//  Soomsil
//
//  Created by 정종인 on 1/1/24.
//  Copyright © 2024 Yourssu. All rights reserved.
//

import Foundation
import CoreData

enum StoreType {
    case persistent, inMemory

    func NSStoreType() -> String {
        switch self {
        case .persistent:
            return NSSQLiteStoreType
        case .inMemory:
            return NSInMemoryStoreType
        }
    }
}

class CoreDataStack {
    static let shared = CoreDataStack(storeType: .persistent)

    let storeType: StoreType

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SaintModel")

        if self.storeType == .inMemory {
            let description = NSPersistentStoreDescription()
            description.type = self.storeType.NSStoreType()
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unable to load core data persistent stores: \(error)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // in-memory와 영구 저장소 merge 충돌: in-memory우선
        container.viewContext.shouldDeleteInaccessibleFaults = true // 접근 불가의 결함들을 삭제할 수 있게끔 설정
        container.viewContext.automaticallyMergesChangesFromParent = true // parent의 context가 바뀌면 자동으로 merge되는 설정

        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private init(storeType: StoreType) {
        self.storeType = storeType
    }

    fileprivate func setBackgroundContext(_ context: NSManagedObjectContext) {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy // in-memory와 영구 저장소 merge 충돌: in-memory우선
        context.undoManager = nil // nil인 경우, 실행 취소를 비활성화 (iOS에 디폴트값은 nil, macOS에서는 기본적으로 제공)
    }

    func taskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        setBackgroundContext(taskContext)

        return taskContext
    }

    func performBackgroundTask(task: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { (context) in
            self.setBackgroundContext(context)
            task(context)
        }
    }
}
