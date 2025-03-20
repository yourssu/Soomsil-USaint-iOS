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

                            EmphasizedView(title: "평점 평균", emphasized: String(format: "%.2f", creditCard.gpa), sub: "4.50")
                            EmphasizedView(title: "취득 학점", emphasized: String(format: "%.1f", creditCard.earnedCredit), sub: String(creditCard.graduateCredit))
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
                                Text("성적이 보이지 않는 경우 새로고침 버튼을 눌러주세요!")
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
                .registerYDSToast()
                .overlay(
                    store.isLoading ? CircleLoadingView() : nil
                )
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            Task {
                                store.send(.onRefresh)
                            }
                        } label: {
                            YDSIcon.refreshLine
                                .renderingMode(.template)
                                .foregroundColor(YDSColor.buttonNormal)
                        }
                    }
                }
            }
        }
    }
}

private extension SemesterListView {
    struct EmphasizedView: View {
        let title: String
        let emphasized: String
        let sub: String

        private var isMini: Bool {
            UIScreen.main.bounds.width <= 375
        }

        var body: some View {
            VStack(alignment: .leading) {
                Text("\(title)")
                    .font(YDSFont.subtitle2)
                HStack(alignment: .firstTextBaseline) {
                    Text("\(emphasized)")
                        .font(isMini ? YDSFont.display2 : YDSFont.display1)
                        .foregroundColor(YDSColor.textPointed)
                    Text("/ \(sub)")
                        .font(isMini ? YDSFont.button1 : YDSFont.button0)
                        .foregroundColor(YDSColor.textTertiary)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SemesterListView(store: Store(initialState: SemesterListReducer.State(totalReportCard: TotalReportCard(gpa: 4.5, earnedCredit: 133.0, graduateCredit: 123.0))) {
        SemesterListReducer()
    })
}
