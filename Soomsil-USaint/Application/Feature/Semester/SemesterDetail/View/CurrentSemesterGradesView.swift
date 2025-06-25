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
                Text("\(Int(gradeSummary.year).formatted(.number.grouping(.never)))년 \(gradeSummary.semester)")
                    .font(YDSFont.subtitle2)
                    .foregroundStyle(.titleText)
                HStack(alignment: .lastTextBaseline) {
                    Text(String(format: "%.2f", lectures.averageGPA))
                        .font(YDSFont.display1)
                    Text("/ 4.50")
                        .foregroundStyle(.grayText)
                }
                Text("해당 학점은 현재 등록된 학점을 기준으로 계산되었습니다. \n P/F 과목은 GPA 계산에서 제외됩니다.")
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
                        LazyVStack {
                            ForEach(lectures, id: \.self.code) { lecture in
                                GradeRowView(lectureDetail: lecture)
                            }
                        }
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
                    Text("아직 등록된 성적이 없어요")
                        .font(YDSFont.subtitle2)
                        .foregroundColor(.titleText)
                    
                    Text("성적이 등록되면 여기에 표시됩니다")
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
