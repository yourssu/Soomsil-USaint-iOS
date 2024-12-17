//
//  HomeItem.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/16/24.
//

public enum HomeItem: Hashable {
    case grade
    case chapel(ChapelType = .location)
    case graduation

    public enum ChapelType {
        case location
        case attendance
    }

    var listTitle: String {
        switch self {
        case .grade: return "내 성적"
        case .chapel: return "채플"
        case .graduation: return "졸업사정표"
        }
    }

    var title: String {
        switch self {
        case .grade:
            "성적 확인하기"
        case .chapel(let chapelType):
            switch chapelType {
            case .location:
                "좌석 위치 확인하기"
            case .attendance:
                "출석 횟수 확인하기"
            }
        case .graduation:
            "졸업 이수 요건 확인하기"
        }
    }

    var subTitle: String {
        switch self {
        case .grade:
            "두근두근 지난 학기"
        case .chapel(let chapelType):
            switch chapelType {
            case .location:
                "내 자리가 어디였지?"
            case .attendance:
                "몇 번 갔더라?"
            }
        case .graduation:
            "졸업까지 몇 학점 남았지?"
        }
    }
}
