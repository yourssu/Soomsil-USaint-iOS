//
//  HomeView.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 11/16/25.
//

import SwiftUI
import YDS_SwiftUI

struct HomeView: View {
    //TODO: 제거
    var testChapelCard: ChapelCard = ChapelCard(attendance: 4, seatPosition: "A-15-1", floorLevel: 1, status: .active)
    
    var body: some View {
        VStack {
            title
            VStack {
                Spacer()
                
                ChapelInfo(chapelCard: testChapelCard)
                
                Spacer()
                
                logoutButton
            }
        }
        .background(.backgroundSurface)
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
    
    var logoutButton: some View {
        Button {
            
        } label: {
            Text("로그아웃")
                .foregroundStyle(.smallText)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(.error, in: RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .padding(16)
        .padding(.bottom, 20)
    }
}
