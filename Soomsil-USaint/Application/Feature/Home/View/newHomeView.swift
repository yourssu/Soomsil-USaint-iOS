//
//  newHomeView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/23/25.
//

import SwiftUI

import YDS_SwiftUI

struct newHomeView: View {
    @State private var testStudent = StudentInfo(name: "이조은", major: "글로벌미디어학부", schoolYear: "3학년")
    @State private var testReportCard = TotalReportCard(gpa: 4.2, earnedCredit: 133, graduateCredit: 133)

    var body: some View {
        VStack {
            title
            VStack {
                Student(student: $testStudent)
                GradeInfo(reportCard: $testReportCard)
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .background(Color(red: 0.95, green: 0.96, blue: 0.97))
    }

    struct Student: View {
        @Binding var student: StudentInfo

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
                .padding(.leading)
                Spacer()
                Button(action: {
                    // MARK: - SettingView로 이동
                }, label: {
                    Image("ic_setting_fill")
                })
            }
            .padding(.horizontal, 16.0)
            .padding(.vertical, 20.0)
        }
    }

    struct GradeInfo: View {
        @Binding var reportCard: TotalReportCard

        var body: some View {
            Button(action: {
                // MARK: - SemesterList로 이동
            }, label: {
                VStack {
                    VStack(spacing: 0) {
                        HStack {
                            Text("내 성적")
                                .font(YDSFont.title3)
                            Spacer()
                        }
                        .padding(.leading, 4)
                        .padding(.top, 20)

                        HStack {
                            Image("ppussung")
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 48, height: 48)
                                .padding(.leading, 0)
                            VStack(alignment: .leading) {
                                Text("전체 학기")
                                    .font(YDSFont.body2)
                                    .padding(.bottom, -2.0)
                                Text("성적 확인하기")
                                    .font(YDSFont.subtitle1)
                            }
                            .padding(.leading, 10)
                            Spacer()
                            YDSIcon.arrowRightLine
                                .renderingMode(.template)
                                .foregroundColor(YDSColor.buttonNormal)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(YDSColor.bgElevated)
                        .frame(height: 72)

                        VStack(spacing: 0) {
                            credit(title: "평균학점", earned: reportCard.gpa, graduated: 4.50, isInt: false)
                            Divider()
                                .padding(.horizontal, 13)
                            credit(title: "취득학점", earned: reportCard.earnedCredit, graduated: reportCard.graduateCredit, isInt: true)

                            Button(action: {
                                // MARK: -SettingView로 이동
                            }, label: {
                                Text("전체 학기 성적 보기")
                                    .font(Font.custom("Apple SD Gothic Neo", size: 15))
                                    .foregroundColor(.white)
                                    .frame(height: 39, alignment: .center)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.51, green: 0.43, blue: 0.93))
                                    .cornerRadius(4)
                            })
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .padding(.bottom, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .foregroundStyle(.black)
                .background(YDSColor.bgElevated)
                .cornerRadius(8)
            })
        }

        @ViewBuilder
        private func credit(title: String, earned: Float, graduated: Float, isInt: Bool) -> some View {
            HStack {
                Text(title).font(YDSFont.body1)
                Spacer()
                Text(isInt ? String(Int(earned)) : String(format: "%.2f", earned))
                    .font(YDSFont.subtitle2)
                    .foregroundColor(Color(red: 0.51, green: 0.43, blue: 0.93))
                Text("/ \(isInt ? String(Int(graduated)) : String(format: "%.2f", graduated))")
                    .font(YDSFont.subtitle3)
                    .foregroundColor(Color(red: 0.56, green: 0.58, blue: 0.6))
            }
            .frame(height: 23)
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
        }
    }
}

private extension newHomeView {
    var title: some View {
        HStack {
            Text("유세인트")
                .font(YDSFont.title2)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            Spacer()
        }
        .background(.white)
    }
}

#Preview {
    newHomeView()
}