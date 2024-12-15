//
//  ErrorViewType.swift
//  Soomsil
//
//  Created by 정종인 on 6/2/24.
//  Copyright © 2024 Yourssu. All rights reserved.
//

import Foundation

enum ErrorViewType {
    case networkError
    case notFounded
    case serviceInspection
    case preparingService

    var title: String {
        switch self {
        case .networkError: return "네트워크가 불안정해요."
        case .notFounded: return "이런, 게시글이 삭제되었어요."
        case .serviceInspection: return "서비스가 점검중이에요."
        case .preparingService: return "서비스 준비 중이에요."
        }
    }

    var content: String {
        switch self {
        case .networkError: return "인터넷 연결 상태를 확인해주세요."
        case .notFounded: return "존재하지 않거나 삭제된 글입니다."
        case .serviceInspection: return "숨쉴때는 서버 점검중! 조금만 기다려주세요.\n더 안정적인 숨쉴때가 되어 돌아올게요."
        case .preparingService: return "보다 나은 서비스를 제공하기 위해 준비중이에요."
        }
    }

    var buttonText: String {
        switch self {
        case .networkError, .notFounded, .preparingService: return "홈으로 이동"
        case .serviceInspection: return "앱 종료하기"
        }
    }
}
