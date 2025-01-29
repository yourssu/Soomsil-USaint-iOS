//
//  Semester.swift
//  Soomsil-USaint
//
//  Created by 정지혁 on 1/29/25.
//

import SwiftData

@Model
final class Semester {
//    #Unique<Semester>([\.year, \.semester]) - iOS 18부터 가능
    
    var earnedCredit: Double
    var gpa: Double
    var overallRank: Int
    var overallStudentCount: Int
    var semester: String
    var semesterRank: Int
    var semesterStudentCount: Int
    var year: Int
    
    @Relationship(inverse: \Lecture.semester) var lectures: [Lecture]
    
    init(earnedCredit: Double, gpa: Double, overallRank: Int, overallStudentCount: Int, semester: String, semesterRank: Int, semesterStudentCount: Int, year: Int, lectures: [Lecture]) {
        self.earnedCredit = earnedCredit
        self.gpa = gpa
        self.overallRank = overallRank
        self.overallStudentCount = overallStudentCount
        self.semester = semester
        self.semesterRank = semesterRank
        self.semesterStudentCount = semesterStudentCount
        self.year = year
        self.lectures = lectures
    }
}
