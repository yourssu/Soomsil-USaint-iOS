//
//  newHomeView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/23/25.
//

import SwiftUI

import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    
    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ){
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    StudentInfoView(student: store.studentInfo)

                    Button {
                        store.send(.currentSemesterGradesPressed)
                    } label: {
                        ReportCardView(
                            type: .overview,
                            reportCard: store.totalReportCard
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        store.send(.semesterGradesPressed)
                    } label: {
                        GPAGraphView(
                            type: .bar,
                            semesterList: store.semesterList
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        store.send(.chapelAttendancePressed)
                    } label: {
                        ChapelAttendanceInfoView(
                            type: .attended,
                            chapelCard: store.chapelCard
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
            .background(.white)
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
    var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(TextLiteral.HomeView.greeting(store.studentInfo.name))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.gray850)
                .lineLimit(1)

            Text(TextLiteral.HomeView.notificationSummary(count: 0))
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.gray500)
        }
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
