//
//  GradeRowView.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 3/16/25.
//

import SwiftUI

import YDS_SwiftUI

// MARK: 과목별 정보
struct GradeRowView: View {
    private let title: String
    private let professorName: String
    private let credit: Double
    private let grade: Grade
    
    init(lectureDetail: LectureDetail) {
        self.title = lectureDetail.title
        self.professorName = lectureDetail.professorName
        self.credit = lectureDetail.credit
        self.grade = lectureDetail.grade
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(grade.string)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(YDSFont.subtitle2)
                Text("\(professorName) · \(String(format: "%.1f", credit)) 학점")
                    .font(YDSFont.body2)
                    .foregroundStyle(YDSColor.textTertiary)
            }
            Spacer()
        }
    }
}

#Preview {
    GradeRowView(lectureDetail: LectureDetail(code: "aaa", title: "컴퓨팅적사고", credit: 4.0, score: "PASS", grade: .aMinus, professorName: "이재환, 이순녀"))
}
