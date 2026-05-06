//
//  SemesterDetailView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import SwiftUI

import YDS_SwiftUI

import ComposableArchitecture

struct SemesterDetailView: View {
    // MARK: - Properties
    
    @Bindable var store: StoreOf<SemesterDetailReducer>
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            if store.semesterList.isEmpty {
                ProgressView(TextLiteral.SemesterDetailView.loadingTitle)
                    .tint(.blue600)
                    .controlSize(.large)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        SemesterTabView(
                            tabs: store.tabs,
                            activeTab: $store.activeTab
                        )
                        
                        if let selectedSemester {
                            ReportCardView(reportCard: .summary, semester: selectedSemester)
                            
                            GPAGraphView(
                                type: .line,
                                semesterList: store.semesterList
                            )
                            
                            GradeListView(
                                lectures: selectedSemester.lectures ?? [],
                                rowType: .compact
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(.white)
        .overlay(
            store.isLoading ? CircleLoadingView() : nil
        )
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    store.send(.backButtonTapped)
                } label: {
                    HStack(spacing: 5) {
                        Image("ic_arrow_left_line")
                            .resizable()
                            .frame(width: 19, height: 19)
                        Text(TextLiteral.SemesterDetailView.title)
                            .font(.custom("AppleSDGothicNeo-Bold", size: 20))
                    }
                    .foregroundStyle(.titleText)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        store.send(.refreshButtonTapped)
                    }
                } label: {
                    YDSIcon.refreshLine
                        .renderingMode(.template)
                        .foregroundStyle(.grayText)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: store.toastMessage) { _, toastMessage in
            guard let toastMessage else { return }

            YDSToast(toastMessage, haptic: .failed)
            store.send(.toastShown)
        }
        .registerYDSToast()
    }
}

// MARK: - Data

private extension SemesterDetailView {
    var selectedSemester: GradeSummary? {
        store.semesterList.first {
            semesterID($0) == store.activeTab
        } ?? store.semesterList.first
    }

    /// 학기 ID 생성
    /// - Parameter semester: 학기 성적
    func semesterID(_ semester: GradeSummary) -> String {
        "\(semester.year)년 \(semester.normalizedSemester)"
    }

}

// MARK: - Preview

#Preview {
    NavigationStack {
        SemesterDetailView(store: Store(
            initialState: previewSemesterDetailState
        ) {
            SemesterDetailReducer()
        } withDependencies: {
            $0.gradeClient.getAllSemesterGrades = {
                previewSemesterDetailState.semesterList
            }
            $0.gradeClient.deleteTotalReportCard = {}
            $0.gradeClient.deleteAllSemesterGrades = {}
            $0.gradeClient.fetchTotalReportCard = {
                previewTotalReportCard
            }
            $0.gradeClient.updateTotalReportCard = { _ in }
            $0.gradeClient.fetchAllSemesterGrades = {
                previewSemesterDetailState.semesterList
            }
            $0.gradeClient.updateAllSemesterGrades = { _ in }
        })
    }
}

private let previewSemesterDetailState: SemesterDetailReducer.State = {
    var state = SemesterDetailReducer.State()
    state.semesterList = [
        previewSemester(year: 2025, semester: "1학기", gpa: 3.87, earnedCredit: 20.5, rank: 12, lectures: previewLectureList),
        previewSemester(year: 2024, semester: "2학기", gpa: 4.12, earnedCredit: 18, rank: 8),
        previewSemester(year: 2024, semester: "여름 학기", gpa: 4.5, earnedCredit: 6, rank: 1),
        previewSemester(year: 2024, semester: "1학기", gpa: 3.72, earnedCredit: 17.5, rank: 15),
        previewSemester(year: 2023, semester: "2학기", gpa: 3.58, earnedCredit: 18, rank: 22)
    ]
    state.tabs = state.semesterList.map {
        SemesterTab(semester: $0)
    }
    state.activeTab = "2025년 1학기"
    return state
}()

private let previewTotalReportCard = TotalReportCard(
    gpa: 3.87,
    earnedCredit: 11.5,
    graduateCredit: 188,
    generalRank: 12,
    overallStudentCount: 100
)

private let previewLectureList: [LectureDetail] = [
    LectureDetail(code: "chapel", title: "비전채플", credit: 0.5, score: "P", grade: .pass, professorName: "박영수"),
    LectureDetail(code: "cte", title: "CTE for IT, Engineering", credit: 3.0, score: "A+", grade: .aPlus, professorName: "최민지"),
    LectureDetail(code: "human", title: "인간관계론", credit: 2.0, score: "A-", grade: .aMinus, professorName: "이준호"),
    LectureDetail(code: "media", title: "디지털미디어원리", credit: 3.0, score: "A-", grade: .aMinus, professorName: "김서연"),
    LectureDetail(code: "database", title: "데이터베이스", credit: 3.0, score: "B+", grade: .bPlus, professorName: "전지훈"),
    LectureDetail(code: "algorithm", title: "알고리즘", credit: 3.0, score: "A0", grade: .aZero, professorName: "한유진"),
    LectureDetail(code: "network", title: "컴퓨터네트워크", credit: 3.0, score: "B+", grade: .bPlus, professorName: "오세민"),
    LectureDetail(code: "os", title: "운영체제", credit: 3.0, score: "A-", grade: .aMinus, professorName: "정다은"),
    LectureDetail(code: "software", title: "소프트웨어공학", credit: 3.0, score: "A+", grade: .aPlus, professorName: "윤서현"),
    LectureDetail(code: "ai", title: "인공지능", credit: 3.0, score: "B0", grade: .bZero, professorName: "강민재"),
    LectureDetail(code: "mobile", title: "모바일프로그래밍", credit: 3.0, score: "A0", grade: .aZero, professorName: "문하린"),
    LectureDetail(code: "security", title: "정보보호", credit: 3.0, score: "B+", grade: .bPlus, professorName: "서지안")
]

private func previewSemester(
    year: Int,
    semester: String,
    gpa: Float,
    earnedCredit: Float,
    rank: Int,
    lectures: [LectureDetail] = []
) -> GradeSummary {
    GradeSummary(
        year: year,
        semester: semester,
        gpa: gpa,
        earnedCredit: earnedCredit,
        semesterRank: rank,
        semesterStudentCount: 100,
        overallRank: rank,
        overallStudentCount: 100,
        lectures: lectures
    )
}
