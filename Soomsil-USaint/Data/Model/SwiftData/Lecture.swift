//
//  Untitled.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 1/29/25.
//

import SwiftData

@Model
final class Lecture {
    @Attribute(.unique) var code: String
    var credit: Double
    var grade: String
    var professorName: String
    var score: String
    var title: String
    
    var semester: Semester?
    
    init(code: String, credit: Double, grade: String, professorName: String, score: String, title: String) {
        self.code = code
        self.credit = credit
        self.grade = grade
        self.professorName = professorName
        self.score = score
        self.title = title
    }
}
