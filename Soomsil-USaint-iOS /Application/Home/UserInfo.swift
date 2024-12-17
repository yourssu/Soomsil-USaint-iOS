//
//  UserInfo.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/16/24.
//

import Combine
import UIKit
import SwiftUI

public class UserInfo {
    public static let shared = UserInfo()
    public var userData: [String: String] = [String: String]()

//    public func loadPersonalInformation() async throws -> SNResponse<SNPersonalInformation> {
//        let responseString = try await getData(of: .information)
//        return try SNResponse<SNPersonalInformation>(from: responseString)
//    }

}
