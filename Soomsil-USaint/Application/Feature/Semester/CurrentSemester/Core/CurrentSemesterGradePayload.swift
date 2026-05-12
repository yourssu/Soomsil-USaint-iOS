//
//  CurrentSemesterGradePayload.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/12/26.
//

struct CurrentSemesterGradePayload {
    let year: Int
    let semester: String
    let lectures: [LectureDetail]
}
