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
            if store.state.isLoading {
                ProgressView()
            } else {
                TopSummary(gradeSummary: GradeSummary(year: 2025, semester: "1학기"),
                           lectures: store.state.currentSemesterLectures)
                GradeList(lectures: store.currentSemesterLectures)
                Spacer()
            }
            
        }
        .padding(.top, 58)
        .padding(.horizontal, 20)
    }
    
    struct TopSummary: View {
        var gradeSummary: GradeSummary
        var lectures: [LectureDetail]
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(TextLiteral.CurrentSemesterGradesView.semesterTitle(
                    year: gradeSummary.year,
                    semester: gradeSummary.semester
                ))
                    .font(YDSFont.subtitle2)
                    .foregroundStyle(.titleText)
                HStack(alignment: .lastTextBaseline) {
                    Text(TextLiteral.CurrentSemesterGradesView.averageGPA(lectures.averageGPA))
                        .font(YDSFont.display1)
                    Text(TextLiteral.CurrentSemesterGradesView.maxGPA)
                        .foregroundStyle(.grayText)
                }
                Text(TextLiteral.CurrentSemesterGradesView.gpaCalculationDescription)
                    .foregroundStyle(.grayText)
                    .font(YDSFont.body2)
                Divider()
            }
        }
    }
    
    struct GradeList: View {
        var lectures: [LectureDetail]
        
        var body: some View {
            ScrollView {
                ZStack(alignment: .center) {
                  if lectures.isEmpty {
                        EmptyGradesView()
                    } else {
                        GradeListView(
                            lectures: lectures,
                            rowType: .compact
                        )
                    }
                }
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
                        .font(YDSFont.subtitle2)
                        .foregroundColor(.titleText)
                    
                    Text(TextLiteral.CurrentSemesterGradesView.emptyDescription)
                        .font(YDSFont.body2)
                        .foregroundColor(.grayText)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 60)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    // FIXME
    CurrentSemesterGradesView(store: Store(
        initialState: HomeReducer.State(
            studentInfo: StudentInfo(name: "000", major: "글로벌미디어학부", schoolYear: "6학년"),
            totalReportCard: TotalReportCard(gpa: 4.22, earnedCredit: 34.5, graduateCredit: 124.0, generalRank: 10, overallStudentCount: 100), chapelCard: ChapelCard(attendance: 4, seatPosition: "E-10-4", floorLevel: 1)
        )
    ) {
        HomeReducer()
    }, onDismiss: {})
}
