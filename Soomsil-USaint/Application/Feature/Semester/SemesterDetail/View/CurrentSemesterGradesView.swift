//
//  CurrentSemesterGradesView.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 6/23/25.
//

import SwiftUI

import ComposableArchitecture
import YDS_SwiftUI

struct CurrentSemesterGradesView: View {
    @Bindable var store: StoreOf<HomeReducer>
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            TopSummary(gradeSummary: GradeSummary(year: 2025, semester: "1학기"))
            GradeList(lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우"),
                                 LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우"),
                                 LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우"),
                                 LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우"),
                                 LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우"),
                                 LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우"),
                                 LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우"),
                                 LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우"),
                                 LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")])
            Spacer()
        }
        .padding(.top, 58)
        .padding(.horizontal, 20)
    }
    
    struct TopSummary: View {
        var gradeSummary: GradeSummary
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("\(gradeSummary.year)년 \(gradeSummary.semester)")
                    .font(YDSFont.subtitle2)
                    .foregroundStyle(.titleText)
                HStack(alignment: .lastTextBaseline) {
                    Text(String(format: "%.2f", gradeSummary.gpa))
                        .font(YDSFont.display1)
                    Text("/ 4.50")
                        .foregroundStyle(.grayText)
                }
                Divider()
            }
        }
    }
    
    struct GradeList: View {
        var lectures: [LectureDetail]
        
        var body: some View {
            ScrollView {
                ForEach(lectures, id: \.self.code) { lecture in
                    GradeRowView(lectureDetail: lecture)
                }
            }
        }
    }
}

#Preview {
    // FIXME:
    CurrentSemesterGradesView(store: Store(
        initialState: HomeReducer.State(
            studentInfo: StudentInfo(name: "000", major: "글로벌미디어학부", schoolYear: "6학년"),
            totalReportCard: TotalReportCard(gpa: 4.22, earnedCredit: 34.5, graduateCredit: 124.0, generalRank: 10, overallStudentCount: 100), chapelCard: ChapelCard(attendance: 4, seatPosition: "E-10-4", floorLevel: 1)
        )
    ) {
        HomeReducer()
    }, onDismiss: {})
}
