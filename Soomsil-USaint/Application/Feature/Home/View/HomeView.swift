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
                    Student(student: store.studentInfo) {
                        store.send(.settingPressed)
                    }
                    ReportCardView(reportCard: store.totalReportCard) {
                        store.send(.currentSemesterGradesPressed)
                    } onSemesterGradesPressed: {
                        store.send(.semesterGradesPressed)
                    }
                    
                    ChapelInfo(chapelCard: ChapelCard(
                        attendance: store.chapelCard.attendance,
                        seatPosition: store.chapelCard.seatPosition,
                        floorLevel: store.chapelCard.floorLevel,
                        status: store.chapelCard.status))
                    
                    Spacer()
                }
            }
            .background(.backgroundSurface)
        } destination: { store in
            switch store.case {
            case .setting(let store):
                SettingView(store: store)
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

    struct Student: View {
        var student: StudentInfo

        let onSettingPressed: () -> Void

        var body: some View {
            HStack {
                Image("DefaultProfileImage")
                    .resizable()
                    .cornerRadius(16)
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading) {
                    Text(student.name)
                        .font(YDSFont.subtitle1)
                        .padding(.bottom, 1.0)
                    Text("\(student.major) \(student.schoolYear)")
                        .font(YDSFont.body1)
                }
                .foregroundStyle(.titleText)
                .padding(.leading)
                Spacer()
                Button(action: {
                    onSettingPressed()
                }, label: {
                    Image("ic_setting_fill")
                })
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 32)
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
