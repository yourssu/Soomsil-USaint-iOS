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
    @Bindable var store: StoreOf<CurrentSemesterGradesReducer>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                TopSummary(
                    year: store.currentSemesterYear,
                    semester: store.currentSemester,
                    lectures: store.currentSemesterLectures
                )
                .padding(.bottom, 32)

                GradeList(lectures: store.currentSemesterLectures)
            }
        }
        .padding(.top, 48)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.white)
        .onAppear {
            store.send(.onAppear)
        }
    }

    struct TopSummary: View {
        var year: Int?
        var semester: String?
        var lectures: [LectureDetail]

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text(semesterTitle)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.gray950)
                .padding(.bottom, 4)

                Text(semesterTitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.gray500)
                    .padding(.bottom, 20)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(TextLiteral.CurrentSemesterGradesView.totalGPATitle)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.gray500)

                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(TextLiteral.CurrentSemesterGradesView.averageGPA(lectures.averageGPA))
                                .font(.system(size: 32, weight: .black))
                                .foregroundStyle(.gray950)

                            Text(TextLiteral.CurrentSemesterGradesView.maxGPA)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.gray500)
                        }
                    }

                    Spacer()

                    SummaryMetricView(
                        title: TextLiteral.CurrentSemesterGradesView.earnedCreditTitle,
                        value: TextLiteral.CurrentSemesterGradesView.credit(earnedCredit)
                    )

                    SummaryMetricView(
                        title: TextLiteral.CurrentSemesterGradesView.lectureCountTitle,
                        value: TextLiteral.CurrentSemesterGradesView.lectureCount(lectures.count)
                    )
                }
            }
        }

        private var earnedCredit: Double {
            lectures.reduce(0) { $0 + $1.credit }
        }

        private var semesterTitle: String {
            guard let year, let semester else {
                return TextLiteral.CurrentSemesterGradesView.currentSemesterFallbackTitle
            }

            return TextLiteral.CurrentSemesterGradesView.semesterTitle(
                year: year,
                semester: semester
            )
        }
    }

    struct GradeList: View {
        var lectures: [LectureDetail]

        var body: some View {
            if lectures.isEmpty {
                EmptyGradesView()
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        GradeListView(
                            lectures: lectures,
                            rowType: .detailed,
                            spacing: 8
                        )
                    }
                    .padding(.bottom, 37)
                }
            }
        }
    }

    struct SummaryMetricView: View {
        let title: String
        let value: String

        var body: some View {
            VStack(alignment: .trailing, spacing: 6) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.gray500)

                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.gray950)
            }
        }
    }

    struct EmptyGradesView: View {
        var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.5))
                
                VStack(spacing: 8) {
                    Text(TextLiteral.CurrentSemesterGradesView.emptyTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.gray950)
                    
                    Text(TextLiteral.CurrentSemesterGradesView.emptyDescription)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray500)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 60)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    let state = {
        var state = CurrentSemesterGradesReducer.State()
        state.currentSemesterLectures = previewCurrentSemesterLectures
        state.currentSemesterYear = 2025
        state.currentSemester = "1학기"
        return state
    }()

    CurrentSemesterGradesView(
        store: Store(initialState: state) {
            CurrentSemesterGradesReducer()
        }
    )
}

private let previewCurrentSemesterLectures: [LectureDetail] = [
    LectureDetail(code: "chapel", title: "비전채플", credit: 0.5, score: "P", grade: .pass, professorName: "박영수"),
    LectureDetail(code: "cte", title: "CTE for IT, Engineering", credit: 3.0, score: "A+", grade: .aPlus, professorName: "최민지"),
    LectureDetail(code: "human", title: "인간관계론", credit: 2.0, score: "A-", grade: .aMinus, professorName: "이준호"),
    LectureDetail(code: "media", title: "디지털미디어원리", credit: 3.0, score: "A-", grade: .aMinus, professorName: "김서연"),
    LectureDetail(code: "database", title: "데이터베이스", credit: 3.0, score: "B+", grade: .bPlus, professorName: "한지훈")
]
