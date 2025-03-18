//
//  SemesterListView.swift
//  Soomsil-USaint-iOS
//
//  Created by 최지우 on 12/16/24.
//

import SwiftUI

import ComposableArchitecture
import Rusaint
import YDS_SwiftUI

struct SemesterListView: View {
    @Perception.Bindable var store: StoreOf<SemesterListReducer>
    @State private var rowAnimation = false

    var body: some View {
        WithPerceptionTracking{
            ZStack {
                ScrollView {
                    // MARK: - top
                    VStack(alignment: .leading) {
                        HStack {
                            let creditCard = store.totalReportCard
                            let average = creditCard.gpa
                            let sum = creditCard.earnedCredit
                            let graduateCredit = creditCard.graduateCredit

                            EmphasizedView(title: "평점 평균", emphasized: String(format: "%.2f", average), sub: "4.50")
                            EmphasizedView(title: "취득 학점", emphasized: String(format: "%.1f", sum), sub: String(graduateCredit))
                        }
                        GPAGraphView(semesterList: store.semesterList)
                    }
                    .padding()

                    Rectangle()
                        .frame(height: 8.0)
                        .foregroundColor(YDSColor.borderThin)

                    VStack(alignment: .leading) {
                        if store.state.semesterList.isEmpty {
                            VStack {
                                Text("유세인트에 확정된 성적표가 보이는 곳 입니다.")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 4)
                                Text("성적이 보이지 않는 경우 뷰를 아래로 당겨서 새로고침을 시도해주세요!")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        } else {
                            ForEach(
                                Array(store.state.semesterList.sortedDescending().enumerated()),
                                id: \.offset
                            ) { index, report in
                                SemesterRowView(gradeSummaryModel: report)
                                    .offset(x: rowAnimation ? 0 : 100)
                                    .opacity(rowAnimation ? 1 : 0)
                                    .animation(
                                        .easeIn
                                            .delay(Double(index) * 0.1)
                                            .speed(0.5),
                                        value: rowAnimation
                                    )
                                    .onAppear {
                                        withAnimation {
                                            rowAnimation = true
                                        }
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
                    store.isLoading ? CircleLoadingView() : nil
                )
            }
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
