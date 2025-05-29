//
//  ChapelInfo.swift
//  Soomsil-USaint
//
//  Created by 서준영 on 5/26/25.
//

import SwiftUI

struct Chapel: View {
    var seatPos: String = "1층 A-1-2"
    var attendanceNum: Int = 8
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("채플")
                .font(.system(size: 18, weight: .bold))
                .lineSpacing(5.4) // 130% line height 계산: 18 * 0.3 = 5.4
                .kerning(0) // Letter spacing 0%
                .foregroundStyle(Color(hex: "#101112"))
                .frame(width: 32, height: 23)
            ZStack {
                Rectangle()
                    .frame(width: 350, height: 110)
                    .cornerRadius(16)
                    .foregroundStyle(.white)
                    .shadow(color: Color(hex: "#69603B").opacity(0.07), radius: 7)
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("내 좌석")
                            .font(.system(size: 15))
                            .padding(.leading, 28)
                        Spacer()
                        Text(seatPos)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "#816DEC"))
                            .padding(.trailing, 28)
                    }
                    .frame(width: 350, height: 37)
                    
                    HStack(spacing: 0) {
                        Text("출결 정보")
                            .font(.system(size: 15))
                            .padding(.leading, 28)
                        Spacer()
                        Text("\(attendanceNum)")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "#816DEC"))
                        Text(" / 12")
                            .font(.system(size: 10))
                            .padding(.trailing, 28)
                            .foregroundStyle(Color(hex: "#8E9398"))
                            .offset(y: 2)
                    }
                    .frame(width: 350, height: 37)
                }
                Rectangle() // Divider
                    .foregroundStyle(Color(hex: "#101112").opacity(0.1))
                    .frame(width: 330, height: 0.34)
            }
            .padding(.top, 14.5)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24.5)
    }
}

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


#Preview {
    ZStack {
        Color.yellow
            .edgesIgnoringSafeArea(.all)
        Chapel()
    }
}
