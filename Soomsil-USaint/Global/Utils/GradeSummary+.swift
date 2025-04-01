//
//  GradeSummary+.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 4/1/25.
//

import Foundation

extension GradeSummary {
    /**
     비교할 GradeSummray를 통해 성적이 다른 GradeSummary 내 Lecture Tittle들을 리턴하는 함수
     - Parameters:
        - by: 비교할 GradeSummary
     - Returns: 성적이 다른 과목 Title들 ([String]), 없으면 빈 배열
     */
    func getDifferenceLectureTitleByGradeSummary(by gradeSummary: GradeSummary) -> [String] {
        let lectures = Dictionary(uniqueKeysWithValues: self.lectures?.map { ($0.code, $0) } ?? [])
        let compareLectures = Dictionary(uniqueKeysWithValues: gradeSummary.lectures?.map { ($0.code, $0) } ?? [])
        
        return lectures.compactMap { code, lecture in
            guard let compareLecture = compareLectures[code] else {
                return nil
            }
            return lecture.grade != compareLecture.grade ? lecture.title : nil
        }
    }
}
