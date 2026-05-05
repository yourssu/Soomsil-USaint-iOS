//
//  SaintPersonalInfo.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/16/24.
//

struct StudentInfo {
    let name: String
    let major: String
    let schoolYear: String
    let studentID: String?

    init(
        name: String,
        major: String,
        schoolYear: String,
        studentID: String? = nil
    ) {
        self.name = name
        self.major = major
        self.schoolYear = schoolYear
        self.studentID = studentID
    }
}
