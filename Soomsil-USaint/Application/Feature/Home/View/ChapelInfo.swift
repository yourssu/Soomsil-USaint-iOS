//
//  ChapelInfo.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 5/26/25.
//

import SwiftUI

let mainPurple: Color = Color(hex: "#816DEC")

struct ChapelInfo: View {
    // 받아올 정보
    var attendanceCount: Int = 4
    var seatPosition: String = "1층 A-1-2"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("채플")
                .font(.system(size: 18, weight: .bold))
                .lineSpacing(5.4)
                .kerning(0)
                .foregroundStyle(Color(hex: "#101112"))
                .frame(width: 32, height: 23)
            ZStack {
                Rectangle()
                    .frame(width: 350, height: 130)
                    .cornerRadius(16)
                    .foregroundStyle(.white)
                    .shadow(color: Color(hex: "#FFF").opacity(0.07), radius: 7)
                
                VStack(spacing: 0) {
                    AttendanceView(attendanceCount)
                    SeatPositionView(seatPosition)
                    Divider()
                        .frame(width: 330)
                }
            }
            .padding(.top, 14.5)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24.5)
    }
}

private struct AttendanceView: View {
    let maxAttendanceCount: Int = 12
    var attendanceCount: Int
    var remainToPassCount: Int
    
    init(_ attendanceCount: Int) {
        self.attendanceCount = attendanceCount
        self.remainToPassCount = (maxAttendanceCount / 3) * 2 - attendanceCount
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("Pass까지 ")
                + Text("\(remainToPassCount)회 ")
                    .foregroundStyle(mainPurple)
                + Text("남았어요")
                    .font(.system(size: 15))
                Spacer()
                Text("\(attendanceCount)")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(mainPurple)
                + Text(" / \(maxAttendanceCount)")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#8E9398"))
            }
            .frame(width: 304, height: 23)
            .padding(.bottom, 5)
            
            ProgressView (value: Double(attendanceCount), total: Double(maxAttendanceCount))
                .frame(width: 304, height: 6.6)
                .progressViewStyle(
                    CustomLinearProgressViewStyle(
                        progressColor: mainPurple,
                        trackColor: Color(hex: "#E5E1FA")
                    )
                )
        }
    }
}

private struct CustomLinearProgressViewStyle: ProgressViewStyle {
    var progressColor: Color
    var trackColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 트랙 (진행 안된 부분)
                RoundedRectangle(cornerRadius: 10)
                    .fill(trackColor)
                    .frame(height: 6.6)
                // 진행된 부분
                RoundedRectangle(cornerRadius: 10)
                    .fill(progressColor)
                    .frame(width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0), height: 6.6)
                // Pass 지점
                Rectangle()
                    .fill(mainPurple)
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

private struct SeatPositionView: View {
    var seatPosition: String
    
    init(_ seatPosition: String) {
        self.seatPosition = seatPosition
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text("좌석 정보")
                .font(.system(size: 15))
                .padding(.leading, 28)
            Spacer()
            Text(seatPosition)
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundStyle(mainPurple)
                .padding(.trailing, 28)
        }
        .frame(width: 350, height: 37)
        .padding(.top, 18)
    }
}


#Preview {
    ChapelInfo()
}


// FIXME: Hex 색상코드를 사용하기 위해 임시로 추가
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
