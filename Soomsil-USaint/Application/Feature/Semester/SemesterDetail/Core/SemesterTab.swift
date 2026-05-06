//
//  SemesterTab.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

struct SemesterTab: Identifiable, Hashable, Equatable {
    let id: String

    /// 학기 탭 모델 구성
    /// - Parameter semester: 학기 성적
    init(semester: GradeSummary) {
        self.id = "\(semester.year)년 \(semester.normalizedSemester)"
    }

    /// 학기 탭 모델 구성
    /// - Parameter id: 학기 탭 ID
    init(id: String) {
        self.id = id
    }
}
