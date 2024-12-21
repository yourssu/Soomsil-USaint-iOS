//
//  StackView.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/18/24.
//

import Foundation

enum StackViewType: Hashable {
    case SemesterList
    case SemesterDetail(GradeSummaryModel)
    case Setting
    case WebViewTerm
    case WebViewPrivacy

    // MARK: - 연관값 추가하려면 아래 코드 필요
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .SemesterList:
            hasher.combine("SemesterList")
        case .SemesterDetail(let model):
            hasher.combine("SemesterDetail")
            hasher.combine(model)
        case .Setting:
            hasher.combine("Setting")
        case .WebViewTerm:
            hasher.combine("WebViewTerm")
        case .WebViewPrivacy:
            hasher.combine("WebViewPrivacy")
        }
    }

    static func == (lhs: StackViewType, rhs: StackViewType) -> Bool {
        switch (lhs, rhs) {
        case (.SemesterList, .SemesterList):
            return true
        case (.SemesterDetail(let lhsModel), .SemesterDetail(let rhsModel)):
            return lhsModel == rhsModel
        case (.Setting, .Setting):
            return true
        case (.WebViewTerm, .WebViewTerm):
            return true
        case (.WebViewPrivacy, .WebViewPrivacy):
            return true
        default:
            return false
        }
    }
}

struct StackView: Hashable {
    let type: StackViewType

    init(type: StackViewType) {
        self.type = type
    }
}
