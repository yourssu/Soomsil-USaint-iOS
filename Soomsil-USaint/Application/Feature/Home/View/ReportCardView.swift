//
//  ReportCardView.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 6/4/25.
//

import SwiftUI

import YDS_SwiftUI

struct ReportCardView: View {
    var reportCard: TotalReportCard
    
    let onCurrentSemesterPressed: () -> Void
    let onSemesterGradesPressed: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("내 성적")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.titleText)
                .padding(.bottom, 15)
            
            Button(action: {
                onCurrentSemesterPressed()
            }) {
                HStack(spacing: 0) {
                    Text("이번 학기 성적 확인")
                        .foregroundStyle(.titleText)
                        .font(YDSFont.body1)
                        .padding(.vertical, 19)

                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .foregroundStyle(.grayText)
                        .frame(width: 10, height: 15)
                        .scaledToFill()
                }
                .padding(.horizontal, 28)
                .background(.white)
                .cornerRadius(16)
            }
            .padding(.bottom, 10)
            
            Button(action: {
                onSemesterGradesPressed()
            }) {
                VStack(spacing: 0) {
                    CreditLine(title: "평균학점", earned: reportCard.gpa, graduated: 4.50, isInt: false)
                    CreditLine(title: "취득학점", earned: reportCard.earnedCredit, graduated: reportCard.graduateCredit, isInt: true)
                    CreditLine(title: "전체석차", earned: Float(reportCard.generalRank), graduated: Float(reportCard.overallStudentCount), isInt: true)
                }
                .padding(.vertical, 20)
                .background(.white)
                .cornerRadius(16)
            }
        }
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
        .frame(height: 22)
        .padding(.vertical, 9)
        .padding(.horizontal, 28)
    }
}

#Preview {
    ReportCardView(reportCard: TotalReportCard(gpa: 4.5, earnedCredit: 123, graduateCredit: 188, generalRank: 10, overallStudentCount: 100)) {} onSemesterGradesPressed: {}
        .background(.surface)
        .padding(.horizontal, 20)
}
