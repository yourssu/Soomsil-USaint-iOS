//
//  GradeListView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import SwiftUI

struct GradeListView: View {
    // MARK: - Properties

    private let lectures: [LectureDetail]
    private let rowType: GradeRowView.DisplayType
    private let spacing: CGFloat

    /// 과목 성적 목록 구성
    /// - Parameters:
    ///   - lectures: 과목 성적 목록
    ///   - rowType: row 표시 타입
    ///   - spacing: row 간격
    init(
        lectures: [LectureDetail],
        rowType: GradeRowView.DisplayType = .compact,
        spacing: CGFloat = 12
    ) {
        self.lectures = lectures
        self.rowType = rowType
        self.spacing = spacing
    }

    // MARK: - Body

    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(lectures, id: \.self.code) { lecture in
                GradeRowView(
                    type: rowType,
                    lectureDetail: lecture
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GradeListView(
        lectures: [
            LectureDetail(code: "chapel", title: "비전채플", credit: 0.5, score: "P", grade: .pass, professorName: "박영수"),
            LectureDetail(code: "cte", title: "CTE for IT, Engineering", credit: 3.0, score: "A+", grade: .aPlus, professorName: "최민지"),
            LectureDetail(code: "human", title: "인간관계론", credit: 2.0, score: "A-", grade: .aMinus, professorName: "이준호")
        ],
        rowType: .compact
    )
    .padding()
    .background(.backgroundSurface)
}
