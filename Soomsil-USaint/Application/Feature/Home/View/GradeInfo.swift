//
//  GradeInfoView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 2/2/25.
//

import SwiftUI

import YDS_SwiftUI

struct GradeInfo: View {
    var reportCard: TotalReportCard
    
    let onSemesterListPressed: () -> Void
    let onSemesterDetailPressed: () -> Void
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("내 성적")
                    .font(YDSFont.title3)
                    .padding(.leading, 4)
                    .padding(.top, 20)

                Button(action: {
                    onSemesterListPressed()
                }) {
                    HStack(spacing: 14) {
                        Image("ppussung")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 48, height: 48)
                        VStack(alignment: .leading) {
                            Text("전체 학기")
                                .font(YDSFont.body2)
                                .padding(.bottom, -2.0)
                            Text("성적 확인하기")
                                .font(YDSFont.subtitle1)
                        }
                        Spacer()
                        YDSIcon.arrowRightLine
                            .renderingMode(.template)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.onSurface)
                    .frame(height: 72)
                }
                
                VStack(spacing: 0) {
                    CreditLine(title: "평균학점", earned: reportCard.gpa, graduated: 4.50, isInt: false)
                    Divider()
                        .padding(.horizontal, 13)
                    CreditLine(title: "취득학점", earned: reportCard.earnedCredit, graduated: reportCard.graduateCredit, isInt: true)
                    
                    Button(action: {
                        onSemesterDetailPressed()
                    }, label: {
                        Text("학기별 성적 조회")
                            .font(Font.custom("Apple SD Gothic Neo", size: 15))
                            .foregroundStyle(.smallText)
                            .frame(height: 39, alignment: .center)
                            .frame(maxWidth: .infinity)
                            .background(.vPrimary)
                            .cornerRadius(4)
                    })
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 4)
                }
            }
            .padding(.horizontal, 16)
        }
        .foregroundStyle(.titleText)
        .background(.onSurface)
        .cornerRadius(8)
    }
}

struct CreditLine: View {
    let title: String
    let earned: Float
    let graduated: Float
    let isInt: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(YDSFont.body1)
                .foregroundStyle(.titleText)
            Spacer()
            Text(isInt ? String(Int(earned)) : String(format: "%.2f", earned))
                .font(YDSFont.subtitle2)
                .foregroundStyle(.vPrimary)
            Text("/ \(isInt ? String(Int(graduated)) : String(format: "%.2f", graduated))")
                .font(YDSFont.subtitle3)
                .foregroundStyle(.grayText)
        }
        .frame(height: 23)
        .padding(.vertical, 8)
        .padding(.horizontal, 24)
    }
}

#Preview {
    GradeInfo(
        reportCard: TotalReportCard(gpa: 4.5, earnedCredit: 123, graduateCredit: 188),
        onSemesterListPressed: {},
        onSemesterDetailPressed: {}
    )
}
