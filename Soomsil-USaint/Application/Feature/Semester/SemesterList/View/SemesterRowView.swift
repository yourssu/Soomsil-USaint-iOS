//
//  SemesterRowView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 2/17/25.
//

import SwiftUI

import YDS_SwiftUI

// MARK: 학기별 정보
struct SemesterRowView: View {
    let year: String
    let semester: String
    let earnedCredit: Float
    let semesterGPA: Float

    init(gradeSummaryModel: GradeSummary) {
        self.year = String(gradeSummaryModel.year)
        self.semester = gradeSummaryModel.semester
        self.earnedCredit = gradeSummaryModel.earnedCredit
        self.semesterGPA = gradeSummaryModel.gpa
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1.0) {
                HStack {
                    Text("\(year)년 \(semester)")
                        .font(YDSFont.subtitle2)
                        .foregroundColor(.titleText)
                }
                Text("\(String(format: "%.1f", earnedCredit))학점")
                    .font(YDSFont.body1)
                    .foregroundColor(.grayText)
            }
            Spacer()
            Text("\(String(format: "%.2f", semesterGPA))")
                .font(YDSFont.button0)
                .foregroundColor(.grayText)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 8.0)
    }
}

#Preview {
    SemesterRowView(gradeSummaryModel:
                        GradeSummary(year: 2024, semester: "2 학기", gpa: 4.5, earnedCredit: 17.5, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")]))
}
