//
//  SemesterListView.swift
//  Soomsil-USaint-iOS
//
//  Created by 최지우 on 12/16/24.
//

import SwiftUI

import YDS_SwiftUI
import Rusaint
import ComposableArchitecture

struct SemesterListView: View {
    @Perception.Bindable var store: StoreOf<SemesterListReducer>
    @State private var rowAnimation = false

    let testReportCard = TotalReportCard(
        gpa: 4.5, earnedCredit: 123.0,
        graduateCredit: 123.0
    )

    let testSemesterList: [GradeSummary] = [
        GradeSummary(year: 2024, semester: "2 학기", gpa: 3.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.0", grade: .aZero, professorName: "최지우")]),
        GradeSummary(year: 2024, semester: "1 학기", gpa: 4.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 4.0, score: "3.3", grade: .aZero, professorName: "이조은")]),
        GradeSummary(year: 2023, semester: "1 학기", gpa: 3.5, earnedCredit: 133, semesterRank: 11, semesterStudentCount: 100, overallRank: 22, overallStudentCount: 22, lectures: [LectureDetail(code: "202", title: "기업가정신", credit: 3.0, score: "4.3", grade: .aZero, professorName: "이조은")])
    ]

    var body: some View {
        ZStack {
            ScrollView {
                // MARK: - top
                VStack(alignment: .leading) {
                    HStack {
                        let creditCard = testReportCard
                        let average = creditCard.gpa
                        let sum = creditCard.earnedCredit
                        let graduateCredit = creditCard.graduateCredit

                        EmphasizedView(title: "평점 평균", emphasized: String(format: "%.2f", average), sub: "4.50")
                        EmphasizedView(title: "취득 학점", emphasized: String(format: "%.1f", sum), sub: String(graduateCredit))
                    }
                    GPAGraphView(semesterList: testSemesterList)
                }
                .padding()

                Rectangle()
                    .frame(height: 8.0)
                    .foregroundColor(YDSColor.borderThin)

                VStack(alignment: .leading) {
                    ForEach(
                        Array(store.state.semesterList.enumerated()),
                        id: \.offset
                    ) { index, report in
                        SemesterRowView(gradeSummaryModel: report)
                            .offset(x: self.rowAnimation ? 0 : 100)
                            .opacity(self.rowAnimation ? 1 : 0)
                            .animation(
                                .easeIn
                                    .delay(Double(index) * 0.1)
                                    .speed(0.5),
                                value: self.rowAnimation
                            )
                            .onAppear {
                                withAnimation {
                                    self.rowAnimation = true
                                }
                            }
                    }
                }
                .padding()
            }
            .background(YDSColor.bgElevated)
            .onAppear {
                store.send(.onAppear)
            }
            .refreshable {
                store.send(.onRefresh)
            }
            .registerYDSToast()
            .overlay(
                store.state.isLoading ? CircleLoadingView() : nil
            )
        }
    }
}

private extension SemesterListView {
    struct EmphasizedView: View {
        let title: String
        let emphasized: String
        let sub: String

        var body: some View {
            VStack(alignment: .leading) {
                Text("\(title)")
                    .font(YDSFont.subtitle2)
                HStack(alignment: .firstTextBaseline) {
                    Text("\(emphasized)")
                        .font(YDSFont.display1)
                        .foregroundColor(YDSColor.textPointed)
                    Text("/ \(sub)")
                        .font(YDSFont.button0)
                        .foregroundColor(YDSColor.textTertiary)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SemesterListView(store: Store(initialState: SemesterListReducer.State()) {
        SemesterListReducer()
    })
}
