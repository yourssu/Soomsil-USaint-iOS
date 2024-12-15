//
//  BaseViewModel.swift
//  Rusaint-iOS
//
//  Created by 이조은 on 12/16/24.
//

import Foundation

import RxCocoa
import RxSwift

public protocol BaseViewBindable {
    var viewDidLoad: PublishRelay<Void> { get }
    var viewWillAppear: PublishRelay<Void> { get }
    var viewDidAppear: PublishRelay<Void> { get }
    var viewWillDisappear: PublishRelay<Void> { get }
    var viewDidDisappear: PublishRelay<Void> { get }
    var disposeBag: DisposeBag { get }
}

public class BaseViewModel: BaseViewBindable {
    public let viewDidLoad = PublishRelay<Void>()
    public let viewWillAppear = PublishRelay<Void>()
    public let viewDidAppear = PublishRelay<Void>()
    public let viewWillDisappear = PublishRelay<Void>()
    public let viewDidDisappear = PublishRelay<Void>()
    public let finishForPop = PublishRelay<Void>()
    public let finishForDismiss = PublishRelay<Void>()
    public let disposeBag = DisposeBag()

    public init() {
        SoomsilLog.debug("[VM LifeCycle] \(Self.self) init")
    }

    deinit {
        SoomsilLog.debug("[VM LifeCycle] \(Self.self) deinit")
    }
}

public final class SoomsilLog {
    public static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let output = items.map { "\($0)" }.joined(separator: separator)
        print("🗣 [\(getCurrentTime())] \(output)", terminator: terminator)
    }

    public static func warning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let output = items.map { "\($0)" }.joined(separator: separator)
        print("⚡️ [\(getCurrentTime())] \(output)", terminator: terminator)
    }

    public static func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let output = items.map { "\($0)" }.joined(separator: separator)
        print("🚨 [\(getCurrentTime())] \(output)", terminator: terminator)
    }

    fileprivate static func getCurrentTime() -> String {
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return dateFormatter.string(from: now as Date)
    }
}
