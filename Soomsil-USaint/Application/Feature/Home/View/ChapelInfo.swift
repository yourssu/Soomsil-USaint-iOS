//
//  ChapelInfo.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 5/26/25.
//

import SwiftUI

struct ChapelInfo: View {
    // 받아오는 정보
    var chapelCard: ChapelCard
    var attendanceCount: Int { chapelCard.attendance }
    var seatPosition: String {
        chapelCard.seatPosition.components(separatedBy: .whitespaces).joined()
    }
    var floorLevel: UInt32 { chapelCard.floorLevel }
    var status: ChapelStatus { chapelCard.status }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("채플")
                .font(.system(size: 18, weight: .bold))
                .lineSpacing(5.4)
                .kerning(0)
                .foregroundStyle(.titleText)
                .frame(width: 32, height: 23)
            
            ZStack {
                Rectangle()
                    .frame(width: 350, height: 130)
                    .cornerRadius(16)
                    .foregroundStyle(.onSurface)
                    .shadow(color: .shadow, radius: 7)
                
                switch status {
                case .active:
                    ActiveStatusView(attendanceCount, seatPosition, floorLevel)
                case .inactive:
                    InactiveStatusView()
                }
            }
            .padding(.top, 14.5)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24.5)
    }
}

private struct ActiveStatusView: View {
    let attendanceCount: Int
    let seatPosition: String
    let floorLevel: UInt32
    
    init(_ attendanceCount: Int, _ seatPosition: String, _ floorLevel: UInt32) {
        self.attendanceCount = attendanceCount
        self.seatPosition = seatPosition
        self.floorLevel = floorLevel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            AttendanceView(attendanceCount)
            Divider()
                .frame(width: 330)
                .padding(.vertical, 18)
            SeatPositionView(seatPosition, floorLevel)
            Spacer()
        }
        .frame(height: 132.34)
    }
}

private struct InactiveStatusView: View {
    var body: some View {
        Text("채플 수료 완료!")
            .font(.system(size: 18))
            .fontWeight(.semibold)
            .foregroundStyle(.vPrimary)
    }
}

private struct AttendanceView: View {
    let maxAttendanceCount: Int = 12
    var attendanceCount: Int
    var remainToPassCount: Int
    
    init(_ attendanceCount: Int) {
        self.attendanceCount = attendanceCount
        self.remainToPassCount = max(0, (maxAttendanceCount / 3) * 2 - attendanceCount)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("Pass까지 ")
                    .font(.system(size: 15))
                    .foregroundStyle(.titleText)
                + Text("\(remainToPassCount)회 ")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(.vPrimary)
                + Text("남았어요")
                    .font(.system(size: 15))
                    .foregroundStyle(.titleText)
                Spacer()
                Text("\(attendanceCount)")
                    .font(.custom("AppleSDGothicNeoB00", size: 16))
                    .fontWeight(.regular)
                    .foregroundStyle(.vPrimary)
                + Text(" ")
                    .font(.custom("NotoSans", size: 16))
                    .fontWeight(.semibold)
                + Text("/ \(maxAttendanceCount)")
                    .font(.custom("NotoSans", size: 12))
                    .fontWeight(.regular)
                    .foregroundStyle(.grayText)
            }
            .frame(width: 304, height: 23)
            .padding(.bottom, 5)
            
            ProgressView (value: Double(attendanceCount), total: Double(maxAttendanceCount))
                .frame(width: 304, height: 6.6)
                .progressViewStyle(
                    CustomLinearProgressViewStyle(
                        progressColor: .vPrimary,
                        trackColor: Color(ColorResource.secondary)
                    )
                )
        }
        .padding(.top, 18)
    }
}

private struct SeatPositionView: View {
    var seatPosition: String
    var floorLevel: UInt32
    
    init(_ seatPosition: String, _ floorLevel: UInt32) {
        self.seatPosition = seatPosition
        self.floorLevel = floorLevel
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text("좌석 정보")
                .font(.system(size: 15))
            Spacer()
            Text("\(floorLevel)층 " + seatPosition)
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundStyle(.vPrimary)
        }
        .frame(height: 25)
        .padding(.horizontal, 28)
    }
}

private struct CustomLinearProgressViewStyle: ProgressViewStyle {
    var progressColor: Color
    var trackColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(trackColor)
                    .frame(height: 6.6)
                RoundedRectangle(cornerRadius: 10)
                    .fill(progressColor)
                    .frame(width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0), height: 6.6)
                Rectangle()
                    .fill(.vPrimary)
                    .frame(width: 2, height: 9)
                    .cornerRadius(1)
                    .position(
                        x: geometry.size.width * (2.0 / 3.0),
                        y: geometry.size.height / 2
                    )
            }
        }
        .frame(height: 6.6)
    }
}

#Preview {
    ZStack {
        Color(.surface)
            .ignoresSafeArea(.all)
        VStack {
            ChapelInfo(chapelCard: ChapelCard(attendance: 4, seatPosition: "E-10-4", floorLevel: 1))
            ChapelInfo(chapelCard: ChapelCard.inactive())
        }
    }
}
