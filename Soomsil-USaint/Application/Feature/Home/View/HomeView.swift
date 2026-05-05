//
//  newHomeView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/23/25.
//

import SwiftUI

import ComposableArchitecture
import YDS_SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    
    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ){
            VStack {
                title
                VStack(alignment: .leading, spacing: 0) {
                    StudentInfoView(student: store.studentInfo)
                    ReportCardView(
                        type: .overview,
                        reportCard: store.totalReportCard,
                        onCurrentSemesterPressed: {
                            store.send(.currentSemesterGradesPressed)
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    Button {
                        store.send(.semesterGradesPressed)
                    } label: {
                        ReportCardView(
                            type: .summary,
                            reportCard: store.totalReportCard
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    ChapelAttendanceInfoView(
                        type: .attended,
                        chapelCard: store.chapelCard
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    
                    Spacer()
                }
            }
            .background(.backgroundSurface)
        } destination: { store in
            switch store.case {
            case .semesterList(let store):
                SemesterListView(store: store)
            case .web(let store):
                WebView(store: store)
            case .semesterDetail(let store):
                SemesterDetailView(store: store)
            }
        }
        .sheet(
            isPresented: $store.currentSemesterGrades
            )
        {
            NavigationStack {
                CurrentSemesterGradesView(
                    store: store, onDismiss: {
                        store.send(.currentSemesterGradesDismissed)
                    }
                )
                .presentationCornerRadius(20)
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(2/3),
                                      .large])
            }
        }
    
        .onAppear {
            store.send(.onAppear)
        }
    }

}

private extension HomeView {
    var title: some View {
        HStack {
            Text("유세인트")
                .font(YDSFont.title2)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(.navigationBarSurface)
    }
}

#Preview {
    HomeView(store: Store(
        initialState: HomeReducer.State(
            studentInfo: StudentInfo(name: "000", major: "글로벌미디어학부", schoolYear: "6학년"),
            totalReportCard: TotalReportCard(gpa: 4.22, earnedCredit: 34.5, graduateCredit: 124.0, generalRank: 10, overallStudentCount: 100), chapelCard: ChapelCard(attendance: 4, seatPosition: "E-10-4", floorLevel: 1)
        )
    ) {
        HomeReducer()
    })
}
